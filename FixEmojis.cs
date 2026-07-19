using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
        Encoding utf8 = new UTF8Encoding(false);
        string file = "index.html";
        string content = File.ReadAllText(file, utf8);
        
        content = Regex.Replace(content, @"<div class=""card-icon"">.*?</div>(\s*<h3>Surgery Guidance</h3>)", "<div class=\"card-icon\">🏥</div>$1");
        content = Regex.Replace(content, @"<div class=""card-icon"">.*?</div>(\s*<h3>CM Fund Assistance</h3>)", "<div class=\"card-icon\">🤝</div>$1");
        
        File.WriteAllText(file, content, utf8);
        Console.WriteLine("Emoji fixed.");
    }
}
