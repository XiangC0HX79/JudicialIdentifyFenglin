using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.IO;
using System.Runtime.InteropServices;
using System.Xml;
using System.Text;

public partial class DownloadAttach : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        String reportNo = Request.Params["no"];
        String fileName = HttpUtility.UrlDecode(Request.Params["name"]);

        String path = Server.MapPath("Report") + "\\" + reportNo + "\\Attach";
        //String title = reportNo + " " + reportName + ".doc";

        //string fileName = title;
        string filePath = path + "\\" + fileName;

        //以字符流的形式下载文件
        FileStream fs = new FileStream(filePath, FileMode.Open);
        byte[] bytes = new byte[(int)fs.Length];
        fs.Read(bytes, 0, bytes.Length);
        fs.Close();
        Response.ContentType = "application/octet-stream";

        //通知浏览器下载文件而不是打开
        Response.AddHeader("Content-Disposition", "attachment;  filename=" + HttpUtility.UrlEncode(fileName, System.Text.Encoding.UTF8));
        Response.BinaryWrite(bytes);
        Response.Flush();
        Response.End();
    }
}
