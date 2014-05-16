using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.IO;
using System.Runtime.InteropServices;
using System.Xml;
using System.Text;

public partial class DownloadFeedback : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        String no = HttpUtility.UrlDecode(Request.Params["no"]);
        String reportNo = HttpUtility.UrlDecode(Request.Params["reportNo"]);
        String fileName = HttpUtility.UrlDecode(Request.Params["fileName"]);

        String path = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo + "\\跟踪反馈" + no;

        //以字符流的形式下载文件
        FileStream fs = new FileStream(path + "\\" + fileName, FileMode.Open);
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
