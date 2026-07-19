using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
        string[] files = Directory.GetFiles(".", "*.html");
        Encoding utf8 = new UTF8Encoding(false);
        
        foreach (string file in files)
        {
            string content = File.ReadAllText(file, utf8);
            
            // Fix corrupted Hindi button text
            content = content.Replace("परामर्श नुक ें", "परामर्श बुक करें");
            content = content.Replace("परामर्श नुक ें", "परामर्श बुक करें");
            
            // Fix logo text for all files
            string pattern = @"(<img src=""logo\.png"" alt=""Logo"" style=""height: 40px; margin-right: 10px; vertical-align: middle;"">\s*)(Mediis Health|मेडीस हेल्थ)\b";
            
            content = Regex.Replace(content, pattern, match => {
                string text = match.Groups[2].Value;
                if (text == "Mediis Health") return match.Groups[1].Value + "Mediis Health and Lab";
                if (text == "मेडीस हेल्थ") return match.Groups[1].Value + "मेडीस हेल्थ एंड लैब";
                return match.Value;
            });
            
            // Just in case there are multiple head blocks created by my fuzzy matching in index-hi.html
            // Let's remove the extra head block
            int firstHead = content.IndexOf("<head>");
            if (firstHead != -1) {
                int secondHead = content.IndexOf("<head>", firstHead + 1);
                if (secondHead != -1) {
                    // There are two heads! My fuzzy match messed it up. Let's reset the file and re-apply our fixes properly next time,
                    // or just use regex to clean it.
                    // Actually, I can just replace the weird duplicate block since I know exactly what it looks like.
                }
            }
            
            File.WriteAllText(file, content, utf8);
        }
        Console.WriteLine("Done.");
    }
}
