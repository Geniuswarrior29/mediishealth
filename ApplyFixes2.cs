using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
        Encoding utf8 = new UTF8Encoding(false);
        string[] files = Directory.GetFiles(".", "*.html");
        
        string contentEn = File.ReadAllText(@"C:\Users\DELL\.gemini\antigravity-ide\brain\e5eb7fe6-ef4b-4887-a0c7-9af4310b376d\scratch\content_en.html", utf8);
        string contentHi = File.ReadAllText(@"C:\Users\DELL\.gemini\antigravity-ide\brain\e5eb7fe6-ef4b-4887-a0c7-9af4310b376d\scratch\content_hi.html", utf8);
        
        foreach (string file in files)
        {
            string content = File.ReadAllText(file, utf8);
            
            // 1. Remove login modals
            content = Regex.Replace(content, @"(?s)<!-- Login Modal -->.*?</div>\s*</div>", "");
            content = Regex.Replace(content, @"(?s)<!-- Signup Modal -->.*?</div>\s*</div>", "");
            content = Regex.Replace(content, @"<a href=""#"" class=""btn btn-outline login-btn"">.*?</a>", "");
            content = Regex.Replace(content, @"<a href=""#"" class=""btn btn-primary signup-btn"">.*?</a>", "");
            
            // 2. Inject 2000 words for index
            if (file.EndsWith("index.html") && !content.Contains("The Power of Ayurveda Section"))
            {
                content = content.Replace("<!-- Footer -->", contentEn + "\r\n    <!-- Footer -->");
                content = content.Replace("https://images.unsplash.com/photo-1579684385127-1ef15d508118?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://i.pinimg.com/736x/18/96/59/18965902b661ccbae66d01d72211ed5c.jpg");
                content = content.Replace("https://i.pinimg.com/1200x/77/5b/4c/775b4c9b555ba7ec342f55829dbedeac.jpg", "https://i.pinimg.com/736x/18/96/59/18965902b661ccbae66d01d72211ed5c.jpg");
            }
            if (file.EndsWith("index-hi.html") && !content.Contains("आयुर्वेद की शक्ति"))
            {
                content = content.Replace("<!-- Footer -->", contentHi + "\r\n    <!-- Footer -->");
                content = content.Replace("https://images.unsplash.com/photo-1579684385127-1ef15d508118?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80", "https://i.pinimg.com/736x/18/96/59/18965902b661ccbae66d01d72211ed5c.jpg");
                content = content.Replace("https://i.pinimg.com/1200x/77/5b/4c/775b4c9b555ba7ec342f55829dbedeac.jpg", "https://i.pinimg.com/736x/18/96/59/18965902b661ccbae66d01d72211ed5c.jpg");
            }
            
            // 3. Fix Logo Text and Image globally
            string logoName = file.EndsWith("-hi.html") ? "मेडीस हेल्थ एंड लैब" : "Mediis Health and Lab";
            content = Regex.Replace(content, @"(?s)(<a href=""[^""]+"" class=""logo"">\s*)(<svg[^>]+>.*?</svg>|<img[^>]+>)\s*(Mediis Health|मेडीस हेल्थ)\b(\s*</a>)", "$1<img src=\"logo.png\" alt=\"Logo\" style=\"height: 40px; margin-right: 10px; vertical-align: middle;\">\r\n                " + logoName + "$4");
            
            // 4. Move header-actions INSIDE nav-links
            content = Regex.Replace(content, @"(?s)<div class=""header-actions"">.*?</div>", "");
            content = content.Replace("<button class=\"mobile-menu-btn\">&#9776;</button>", "");
            
            string bookBtnText = file.EndsWith("-hi.html") ? "परामर्श बुक करें" : "Book Consultation";
            string selectedHi = file.EndsWith("-hi.html") ? " selected" : "";
            string bookLink = file.EndsWith("-hi.html") ? "book-consultation-hi.html" : "book-consultation.html";
            
            string actions = @"
                <div class=""header-actions"">
                    <select id=""langSelect"" style=""padding: 0.5rem; border:1px solid var(--border); border-radius:4px; outline:none;"">
                        <option value=""en"">Eng</option>
                        <option value=""hi""" + selectedHi + @">हिन्दी</option>
                    </select>
                    <a href=""" + bookLink + @""" class=""btn btn-primary"" style=""color: white !important;"">" + bookBtnText + @"</a>
                </div>";
                
            content = Regex.Replace(content, @"(?s)(</nav>)", actions + "\r\n            $1\r\n            <button class=\"mobile-menu-btn\">&#9776;</button>");
            
            File.WriteAllText(file, content, utf8);
        }
        Console.WriteLine("All HTML fixes applied successfully in C#.");
    }
}
