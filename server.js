require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Razorpay = require('razorpay');
const crypto = require('crypto');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// Connect to SQLite database
const dbPath = path.join(__dirname, 'database.sqlite');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Could not connect to database', err);
    } else {
        console.log('Connected to SQLite database');
        // Create table if not exists
        db.run(`
            CREATE TABLE IF NOT EXISTS consultations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                age TEXT,
                phone TEXT,
                email TEXT,
                conditions TEXT,
                description TEXT,
                razorpay_order_id TEXT,
                razorpay_payment_id TEXT,
                status TEXT DEFAULT 'pending',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `, (err) => {
            if (!err) {
                // Try to add the status column in case the table already existed before this update
                db.run(`ALTER TABLE consultations ADD COLUMN status TEXT DEFAULT 'pending'`, (alterErr) => {
                    // Ignore alterErr because it simply means the column already exists
                });
            }
        });
    }
});

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname)); // Serve static HTML files from the same directory

// Initialize Razorpay instance
const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Endpoint to create an order
app.post('/api/create-order', async (req, res) => {
    try {
        const { amount, currency, receipt } = req.body;

        if (!amount || amount < 100) {
            return res.status(400).json({ error: 'Amount must be at least 100 paise' });
        }

        const options = {
            amount: amount, // amount in the smallest currency unit
            currency: currency || "INR",
            receipt: receipt || `receipt_${Date.now()}`
        };

        const order = await razorpay.orders.create(options);
        res.json({
            order_id: order.id,
            amount: order.amount,
            currency: order.currency
        });
    } catch (error) {
        console.error("Razorpay Error:", error);
        res.status(500).json({ error: 'Failed to create order' });
    }
});

// Endpoint to verify payment signature
app.post('/api/verify-payment', (req, res) => {
    try {
        const { razorpay_order_id, razorpay_payment_id, razorpay_signature, patient } = req.body;

        if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        const body = razorpay_order_id + "|" + razorpay_payment_id;

        const expectedSignature = crypto
            .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
            .update(body.toString())
            .digest('hex');

        if (expectedSignature === razorpay_signature) {
            // Insert patient data into database
            if (patient) {
                const stmt = db.prepare(`
                    INSERT INTO consultations (name, age, phone, email, conditions, description, razorpay_order_id, razorpay_payment_id)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                `);
                stmt.run(
                    patient.name,
                    patient.age,
                    patient.phone,
                    patient.email,
                    patient.conditions,
                    patient.description,
                    razorpay_order_id,
                    razorpay_payment_id,
                    function(err) {
                        if (err) {
                            console.error("Database insert error:", err);
                        } else {
                            console.log("Patient record saved with ID:", this.lastID);
                        }
                    }
                );
                stmt.finalize();
            }

            res.json({ success: true, message: 'Payment verified successfully' });
        } else {
            res.status(400).json({ success: false, error: 'Invalid signature' });
        }
    } catch (error) {
        console.error("Verification Error:", error);
        res.status(500).json({ error: 'Internal server error during verification' });
    }
});

// GET Endpoint to fetch all consultations for Admin Portal
app.get('/api/consultations', (req, res) => {
    db.all(`SELECT * FROM consultations ORDER BY id DESC`, [], (err, rows) => {
        if (err) {
            console.error(err);
            res.status(500).json({ error: 'Failed to retrieve consultations' });
        } else {
            res.json(rows);
        }
    });
});

// POST Endpoint to update consultation status
app.post('/api/consultations/:id/status', (req, res) => {
    const id = req.params.id;
    const { status } = req.body;
    
    if (status !== 'pending' && status !== 'completed') {
        return res.status(400).json({ error: 'Invalid status' });
    }

    const stmt = db.prepare(`UPDATE consultations SET status = ? WHERE id = ?`);
    stmt.run(status, id, function(err) {
        if (err) {
            console.error(err);
            res.status(500).json({ error: 'Failed to update status' });
        } else {
            res.json({ success: true, changes: this.changes });
        }
    });
    stmt.finalize();
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
    console.log(`Open http://localhost:${PORT}/book-consultation.html to test.`);
});
