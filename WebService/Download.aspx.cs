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

using System.Threading;
using System.Diagnostics; 

public partial class Download : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            String reportNo = HttpUtility.UrlDecode(Request.Params["reportNo"]);
            String fileName = HttpUtility.UrlDecode(Request.Params["fileName"]);

            String path = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo;

            //以字符流的形式下载文件
            FileStream fs = new FileStream(ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo + "\\" + fileName, FileMode.Open);
            byte[] byteArr = new byte[(int)fs.Length];
            fs.Read(byteArr, 0, byteArr.Length);
            fs.Close();

            Response.BinaryWrite(byteArr); 
            Response.Flush();
            Response.Clear();
        }
        catch (Exception ex)
        {
            Debug.Write(ex.Message);

            Response.Write(ex.Message);
        }

        Response.End();
    }
}
