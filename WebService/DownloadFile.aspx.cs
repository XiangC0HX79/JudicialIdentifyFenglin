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

using System.Threading;
using System.Diagnostics;

public partial class DownloadFile : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            String year = HttpUtility.UrlDecode(Request.Params["year"]);
            String type = HttpUtility.UrlDecode(Request.Params["type"]);
            String reprortNo = HttpUtility.UrlDecode(Request.Params["reprortNo"]);

            String groupid = HttpUtility.UrlDecode(Request.Params["group"]);

            String group = "残鉴字";
            if(groupid == "0")
                group = "残鉴字";
            else if (groupid == "1")
                group = "三鉴字";
            else if (groupid == "2")
                group = "伤鉴字";
            else if (groupid == "3")
                group = "精鉴字";
            else if (groupid == "4")
                group = "待定";

            Service ws = new Service();
            if (ws.BackReport(year, "", type, reprortNo) == "000")
            {
                String path = Server.MapPath("Backup") + "\\沪枫林 " + year + " " + group + " " + int.Parse(reprortNo).ToString("0000") + "号" + ".zip";

                //以字符流的形式下载文件
                FileStream fs = new FileStream(path, FileMode.Open);
                byte[] byteArr = new byte[(int)fs.Length];
                fs.Read(byteArr, 0, byteArr.Length);
                fs.Close();

                Response.BinaryWrite(byteArr);
                Response.Flush();
                Response.Clear();

                File.Delete(path);
            }
        }
        catch (Exception ex)
        {
            Debug.Write(ex.Message);

            Response.Write(ex.Message);
        }

        Response.End();
    }
}
