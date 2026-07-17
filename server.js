const express = require('express');
const cors = require('cors');
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
                address TEXT,
                status TEXT DEFAULT 'pending',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `, (err) => {
            if (!err) {
                // Try to add the status column in case the table already existed before this update
                db.run(`ALTER TABLE consultations ADD COLUMN status TEXT DEFAULT 'pending'`, (alterErr) => {});
                // Try to add the address column
                db.run(`ALTER TABLE consultations ADD COLUMN address TEXT`, (alterErr) => {});
            }
        });
    }
});

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname)); // Serve static HTML files from the same directory

// Endpoint to submit consultation details (No payment)
app.post('/api/submit-consultation', (req, res) => {
    try {
        const { patient } = req.body;

        if (!patient) {
            return res.status(400).json({ error: 'Missing patient data' });
        }

        const stmt = db.prepare(`
            INSERT INTO consultations (name, age, phone, email, conditions, description, address)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `);
        stmt.run(
            patient.name,
            patient.age,
            patient.phone,
            patient.email,
            patient.conditions,
            patient.description,
            patient.address || '',
            function(err) {
                if (err) {
                    console.error("Database insert error:", err);
                    res.status(500).json({ error: 'Failed to save consultation' });
                } else {
                    console.log("Patient record saved with ID:", this.lastID);
                    res.json({ success: true, message: 'Consultation submitted successfully' });
                }
            }
        );
        stmt.finalize();

    } catch (error) {
        console.error("Submission Error:", error);
        res.status(500).json({ error: 'Internal server error' });
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
