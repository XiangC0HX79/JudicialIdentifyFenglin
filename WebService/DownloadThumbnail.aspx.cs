using System;
using System.Configuration;
using System.Drawing.Imaging;
using System.IO;
using System.Web;
using System.Drawing;

public partial class DownloadThumbnail : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            var reportNo = HttpUtility.UrlDecode(Request.Params["reportNo"]);
            var fileName = HttpUtility.UrlDecode(Request.Params["fileName"]);

            var w = Convert.ToInt32(HttpUtility.UrlDecode(Request.Params["w"]));
            var h = Convert.ToInt32(HttpUtility.UrlDecode(Request.Params["h"]));

            var oi = Image.FromFile(ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo + "\\" + fileName);

            var scale = Math.Min((Double)w / oi.Width, (Double)h / (oi.Height));

            w = (int)(scale * oi.Width);
            h = (int)(scale * oi.Height);

            var ni = oi.GetThumbnailImage(w, h, () => false, IntPtr.Zero); // 对原图片进行缩放 

            var sm = new MemoryStream();
            ni.Save(sm, ImageFormat.Png);

            sm.Position = 0;

            //以字符流的形式下载文件
            var b = new byte[(int)sm.Length];
            sm.Read(b, 0, b.Length);
            sm.Close();
            
            oi.Dispose();
            ni.Dispose();

            Response.BinaryWrite(b);
            Response.Flush();
            Response.Clear();
            Response.End();
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
            Response.End();
        }
    }
}
