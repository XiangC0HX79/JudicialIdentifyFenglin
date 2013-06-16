using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.IO;
using System.Runtime.InteropServices;

public partial class PrintTable : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        String file = Request.Params["file"];

        Byte[] byts = new byte[Request.InputStream.Length];
        Request.InputStream.Read(byts, 0, byts.Length);
        String data = Uri.UnescapeDataString(System.Text.Encoding.Default.GetString(byts));

        String path = Server.MapPath("ExcelXlt");

        Excel._Application excel = null;

        Excel._Workbook workBook = null;

        object oMissing = System.Reflection.Missing.Value;

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
            
            excel = new Excel.ApplicationClass();
            excel.Visible = false;

            workBook = excel.Workbooks.Open(path + "\\" + file + ".xlt", oMissing, oMissing, oMissing, oMissing, oMissing, oMissing, oMissing,
                oMissing, oMissing, oMissing, oMissing, oMissing, oMissing, oMissing);
            
            String[] cSplit = { "/C/" };
            String[] rSplit = { "/R/" };
            String[] pSplit = { "/P/" };

            String[] dataPages = data.Split(pSplit, StringSplitOptions.RemoveEmptyEntries);
            for (int p = 0; p < dataPages.Length; p++)
            {
                //if (dataPages[p] == "")
                //    break;

                Excel._Worksheet workSheet = (Excel._Worksheet)workBook.Worksheets[p+1];

                String[] dataRows = dataPages[p].Split(rSplit, StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < dataRows.Length; i++)
                {
                    //if (dataRows[i] == "")
                   //     break;

                    if (i < dataRows.Length - 1)
                    {
                        Excel.Range range = (Excel.Range)workSheet.Rows[i + 2, oMissing];
                        range.Insert(Excel.XlInsertShiftDirection.xlShiftDown, Excel.XlInsertFormatOrigin.xlFormatFromRightOrBelow);
                    }

                    String[] dataColumns = dataRows[i].Split(cSplit, StringSplitOptions.None);
                    for (int j = 0; j < dataColumns.Length; j++)
                        workSheet.Cells[i + 2, j + 1] = dataColumns[j];
                }
            }

            object oSaveFileName = path + "\\Temp\\" + file + ".xls";
            object osaveFileFormat = Excel.XlFileFormat.xlWorkbookNormal;

            workBook.SaveAs(oSaveFileName, Excel.XlFileFormat.xlWorkbookNormal, oMissing, oMissing, oMissing, oMissing, Excel.XlSaveAsAccessMode.xlExclusive,
                oMissing, oMissing, oMissing, oMissing, oMissing);

            workBook.Close(oMissing, oMissing, oMissing);
            workBook = null;

            excel.Quit();
            excel = null;

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

        if (workBook != null)
        {
            workBook.Close(oMissing, oMissing, oMissing);
            Marshal.ReleaseComObject(workBook);
        }

        if (excel != null)
        {
            excel.Quit();
            Marshal.FinalReleaseComObject(excel);
        }

        Response.End();
    }
}
