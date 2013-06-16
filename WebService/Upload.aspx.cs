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

public partial class Upload : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            String reportNo = HttpUtility.UrlDecode(Request.Params["reportNo"]);
            String fileName = HttpUtility.UrlDecode(Request.Params["fileName"]); ;
            String pageIndex = HttpUtility.UrlDecode(Request.Params["pageIndex"]);

            String path = Server.MapPath("Report") + "\\" + reportNo;

            Byte[] byteArr = new Byte[Request.InputStream.Length];
            Request.InputStream.Read(byteArr, 0, byteArr.Length);

            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }

            FileStream file;
            if(Convert.ToInt32(pageIndex) == 0)
                file = new FileStream(path + "\\" + fileName, FileMode.Create);
            else
                file = new FileStream(path + "\\" + fileName, FileMode.Append);

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