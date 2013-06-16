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

public partial class Upload : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        HttpFileCollection files = Request.Files;

        if (files.Count == 0)
        {
            Response.Write("请勿直接访问本文件");
            Response.End();
        }

        HttpPostedFile file = files[0];
        if (file == null || file.ContentLength == 0)
        {
            Response.Write("请先上传文件文件");
            Response.End();
        }

        try
        {
            String reportNo = Request.Params["no"];
            String reportName = Request.Params["name"];

            String path = Server.MapPath("Report");
            path += "\\" + reportNo;

            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }

            String title = "";
            if (reportName == null)
                title = Request.Form["fileName"];
            else
                title = reportName;

            String savePath = path + "\\" + title;
            if (File.Exists(savePath))
            {
                File.Delete(savePath);
            }

            file.SaveAs(savePath);

            Response.Write("<Root><ID>0</ID></Root>");
        }
        catch (Exception ex)
        {
            Response.Write("<Root><ID>-1</ID></Root>");
        }

        Response.End();
    }
}
