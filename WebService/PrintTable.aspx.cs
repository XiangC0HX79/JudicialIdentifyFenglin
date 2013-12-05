using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.IO;
using System.Runtime.InteropServices;

using Aspose.Cells;

public partial class PrintTable : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var file = Request.Params["file"];

        Byte[] byts = new byte[Request.InputStream.Length];
        Request.InputStream.Read(byts, 0, byts.Length);
        String data = Uri.UnescapeDataString(System.Text.Encoding.Default.GetString(byts));

        var path = Server.MapPath("ExcelXlt");
               
        try
        {
            if (!Directory.Exists(path + "\\Temp"))
            {
                Directory.CreateDirectory(path);
            }
            else
            {
                foreach (String pathName in Directory.GetFiles(path + "\\Temp"))
                {
                    File.Delete(pathName);
                }
            }

            var workbook = new Workbook(path + "\\" + file + ".xlt");

            String[] cSplit = { "/C/" };
            String[] rSplit = { "/R/" };
            String[] pSplit = { "/P/" };

            String[] dataPages = data.Split(pSplit, StringSplitOptions.RemoveEmptyEntries);
            for (int p = 0; p < dataPages.Length; p++)
            {
                //if (dataPages[p] == "")
                //    break;

                var workSheet = workbook.Worksheets[p];

                String[] dataRows = dataPages[p].Split(rSplit, StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < dataRows.Length; i++)
                {
                    //if (dataRows[i] == "")
                   //     break;

                    if (i < dataRows.Length - 1)
                    {
                        workSheet.Cells.InsertRow(i+2);
                        //Excel.Range range = (Excel.Range)workSheet.Rows[i + 2, oMissing];
                        //range.Insert(Excel.XlInsertShiftDirection.xlShiftDown, Excel.XlInsertFormatOrigin.xlFormatFromRightOrBelow);
                    }

                    String[] dataColumns = dataRows[i].Split(cSplit, StringSplitOptions.None);
                    for (int j = 0; j < dataColumns.Length; j++)
                        workSheet.Cells[i + 1, j].PutValue(dataColumns[j]);
                }
            }

            //object oSaveFileName = path + "\\Temp\\" + file + ".xls";

            workbook.Save(path + "\\Temp\\" + file + ".xls", FileFormatType.Excel97To2003);

            //以字符流的形式下载文件
            FileStream fs = new FileStream(path + "\\Temp\\" + file + ".xls", FileMode.Open);
            byte[] byteArr = new byte[(int)fs.Length];
            fs.Read(byteArr, 0, byteArr.Length);
            fs.Close();

            Response.BinaryWrite(byteArr);
            Response.Flush();
            Response.Clear();

            Response.Write("<Root><ID>0</ID><Msg>Success</Msg></Root>");
        }
        catch (Exception ex)
        {
            Response.Write("<Root><ID>1</ID><Msg>" + ex.Message + "</Msg></Root>");
        }

        Response.End();
    }
}
