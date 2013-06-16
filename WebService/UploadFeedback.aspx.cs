using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using System.IO;
using System.Text;
using System.Xml;

public partial class UploadFeedback : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            String no = HttpUtility.UrlDecode(Request.Params["no"]);
            String reportNo = HttpUtility.UrlDecode(Request.Params["reportNo"]);
            String fileName = HttpUtility.UrlDecode(Request.Params["fileName"]);

            String path = Server.MapPath("Report") + "\\" + reportNo + "\\跟踪反馈" + no;

            Byte[] byteArr = new Byte[Request.InputStream.Length];
            Request.InputStream.Read(byteArr, 0, byteArr.Length);

            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }

            FileStream file = new FileStream(path + "\\" + fileName, FileMode.Create);
            file.Write(byteArr, 0, byteArr.Length);
            file.Flush();
            file.Close();

            Response.Write("000");
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }

        Response.End();
    }
}