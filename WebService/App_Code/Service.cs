using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.Services;

using System.IO;
using System.Data;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Security.AccessControl;

using ICSharpCode.SharpZipLib.Zip;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。
// [System.Web.Script.Services.ScriptService]
public class Service : System.Web.Services.WebService
{
    private string conStr = "";

    public Service () {

        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 

        conStr = "Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source="
                + Server.MapPath("App_Data/Data.mdb")
                + ";Extended Properties=";
    }

    [WebMethod]
    public string HelloWorld() {
        return "Hello World";
    }

    [WebMethod]
    public Object GetValue(String sql)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetValue(sql);
    }

    [WebMethod]
    public DataTable GetTable(String sql)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable(sql);
    }
       
    [WebMethod]
    public int GetReportCount(String sql)
    {
        var clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        var s = "select count(*) from (" + sql + " )";

        return (int)clsGetData.GetValue(s);
    }

    [WebMethod]
    public DataTable GetReport(String sql,int pageIndex,int pageSize)
    {
        var clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        var s = "select count(*) from (" + sql + " )";

        var c = (int)clsGetData.GetValue(s);
               
        var  size = ((pageIndex*pageSize > c)&&(c>0))?c%pageSize:pageSize;

        s = "select * from (select top " + size + " * from (select top " + (pageIndex * pageSize) + " * from (" +
                sql + " ) order by id desc) order by id) order by id desc";

        return clsGetData.GetTable(s);
    }

    [WebMethod]
    public DataTable SetTable(String sql)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.SetTable(sql);
    }

    [WebMethod]
    public DataTable ExcuteNoQuery(String sql)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.ExcuteNoQuery(sql);
    }

    [WebMethod]
    public String getCurMessage(Int32 id)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "SELECT TOP 10 * FROM 留言板 WHERE 时间 > #" + DateTime.Now.ToString("yyyy-MM-dd") + "# ORDER BY 时间 DESC";
        DataTable result = clsGetData.GetTable(sql);
        if (result.TableName == "Error")
            return clsGetData.ErrorString;

        if (result.Rows.Count == 0)
            return "今天没有人留言。";

        DataRow msgRow = null;
        foreach (DataRow row in result.Rows)
        {
            if(Convert.ToInt32(row["ID"]) < id)
            {
                msgRow = row;
                break; 
            }
        }

        if (msgRow == null)
            msgRow = result.Rows[0];

        String s = "";	
		s += "[" + Convert.ToDateTime(msgRow["时间"]).ToString("HH:mm:ss") + "] ";
	    
	    String name = Convert.ToString(msgRow["姓名"]);
	    if(name.Length == 2)
	    {
            s += name.Substring(0, 1) + "　" + name.Substring(1, 1);
	    }
	    else
	    {
		    s += name;
	    }
					
		s += "：";

        s += Convert.ToString(msgRow["留言"]);

        return s + "|" + Convert.ToString(msgRow["ID"]);
    }

    [WebMethod]
    public DataTable GetAttachInfo(String reportNo)
    {
        DataTable dataTable = new DataTable("Table");
        DataColumn column = new DataColumn("FileName", Type.GetType("System.String"));
        dataTable.Columns.Add(column);

        String path = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo;

        if (!Directory.Exists(path))
            Directory.CreateDirectory(path);

        foreach (String pathName in Directory.GetFiles(path))
        {
            String fileName = pathName.Substring(pathName.LastIndexOf('\\') + 1);
            DataRow row = dataTable.NewRow();
            row["FileName"] = fileName;
            dataTable.Rows.Add(row);
        }
        
        return dataTable;
    }

    [WebMethod]
    public String DeleteAttachImage(String reportNo, String imgName,String facName)
    {
        String img = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo + "\\" + imgName;
        String fac = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo + "\\" + facName;

        if (File.Exists(img))
        {
            File.Delete(img);
        }

        if (File.Exists(fac))
        {
            File.Delete(fac);
        }

        return "000";
    }

    public String getSubNo(String no,Int32 subno)
    {        
		Int32 l  = no.Length;
		for(Int32 i = 4; i>l ; i--)
			no = "0" + no;

        if (subno != 0)
            no += "-" + subno.ToString();

        return no;
    }

    [WebMethod]
    public DataTable BackCase(String reportNo,String type, String backer, String backDate, String backReson)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "SELECT * FROM 报告信息,视图_类型组别 WHERE 编号 = " + reportNo + " AND 类别 = "+type+" AND 次级编号 = 0 AND 报告信息.类别 = 视图_类型组别.参数ID";
        DataTable result = clsGetData.GetTable(sql);
        if (result.TableName == "Error")
            return result;
        
        DataRow report = result.Rows[0];

        Int32 id = Convert.ToInt32(report["ID"]);
        Int32 subID = Convert.ToInt32(clsGetData.GetValue("SELECT MAX(次级编号) FROM 报告信息 WHERE 编号 = " + reportNo + " AND 类别 = " + type));

        String fields = "编号,类别,年度,受理日期,受理人,委托单位,委托单位联系方式" +
                ",委托单位联系人,受检人,受检人联系方式,受理地点,影像资料" +
                ",受理人A,受理人B,受理人C,备注,预计报告日期,预计报告类型,打印人" +
                ",缴费方式,应缴金额,已缴金额,退费金额,是否返佣,返佣金额,开票情况,票号,开票金额" + 
                ",会诊接受日期,会诊日期,会诊人,其他会诊人";
        sql = "INSERT INTO 报告信息 (案件状态," + fields + ") SELECT 1," + fields + " FROM 报告信息 WHERE ID = " + id;
        result = clsGetData.SetTable(sql);
        if (result.TableName == "Error")
            return result;

        sql = "UPDATE 报告信息 SET 次级编号 = " + (subID + 1)
                            + ",案件状态 = 10"
                            + ",退回人 = " + backer
                            + ",退回日期 = #" + backDate
                            + "#,退回原因 = '" + backReson + "'"
                            + " WHERE ID = " + id;
        result = clsGetData.SetTable(sql);
        if (result.TableName == "Error")
            return result;

        try
        {
            String no = report["编号"].ToString();
            String year = report["年度"].ToString();
            String group = report["参数值"].ToString();

            String curDir = ConfigurationManager.AppSettings["reportDir"] + "\\" + "沪枫林 " + year + " " + group + " " + getSubNo(no, 0) +
                            " 号";
            String backDir = ConfigurationManager.AppSettings["reportDir"] + "\\" + "沪枫林 " + year + " " + group + " " +
                             getSubNo(no, subID + 1) + " 号";

            Directory.Move(curDir, backDir);

            Directory.CreateDirectory(curDir);

            foreach (String pathName in Directory.GetFiles(backDir))
            {
                String fileName = pathName.Substring(pathName.LastIndexOf('\\') + 1);
                if ((fileName.IndexOf("初步照片", 0, StringComparison.Ordinal) >= 0) || (fileName.IndexOf("会诊", 0, StringComparison.Ordinal) >= 0))
                {
                    File.Copy(backDir + "\\" + fileName, curDir + "\\" + fileName);
                }
            }
        }
        catch (Exception ex)
        {
        }

        return result;
    }
    
    [WebMethod]
    public String UploadImage(String reportNo,string s)
    {
        var files = s.Split(';');

        String path = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo;

        if (Directory.Exists(path))
        {
            var tmp = path + "\\tmp";
            if (!Directory.Exists(tmp))
                Directory.CreateDirectory(tmp);

            foreach (var file in files)
            {
                if (file == "") continue;

                var dsc = file.Split(' ')[0];
                var src = file.Split(' ')[1];
                File.Copy(path + "\\" + src, tmp + "\\" + dsc);
            }

            foreach (String pathName in Directory.GetFiles(path))
            {
                String fileName = pathName.Substring(pathName.LastIndexOf('\\') + 1);
                if(fileName.IndexOf("初步照片") == 0)
                    File.Delete(pathName);
            }

            foreach (String pathName in Directory.GetFiles(tmp))
            {
                String fileName = pathName.Substring(pathName.LastIndexOf('\\') + 1);
                File.Move(tmp + "\\" + fileName, path + "\\" + fileName);
            }

            Directory.Delete(tmp);
        }
        else
        {
            Directory.CreateDirectory(path);
        }

        return reportNo;
    }

    [WebMethod]
    public String UploadConsultImage(String reportNo)
    {
        String path = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo;

        if (Directory.Exists(path))
        {
            foreach (String pathName in Directory.GetFiles(path))
            {
                String fileName = pathName.Substring(pathName.LastIndexOf('\\') + 1);
                if (fileName.IndexOf("会诊照片") == 0)
                    File.Delete(pathName);
            }
        }
        else
        {
            Directory.CreateDirectory(path);
        }

        return "000";
    }

    [WebMethod]
    public String CopyFstExamin(String reportNo)
    {
        String path = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo;

        String dstFileName = path + "\\鉴定意见书（初审）.doc";
        String srcFileName = path + "\\鉴定意见书（初稿）.doc";
        if (File.Exists(srcFileName) && !File.Exists(dstFileName))
            File.Copy(srcFileName, dstFileName);

        dstFileName = path + "\\成型照片（初审）.doc";
        srcFileName = path + "\\成型照片（初稿）.doc";
        if (File.Exists(srcFileName) && !File.Exists(dstFileName))
            File.Copy(srcFileName, dstFileName);

        return "000";
    }

    [WebMethod]
    public String CopySndExamin(String reportNo)
    {
        String path = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo;

        String dstFileName = path + "\\鉴定意见书（复审）.doc";
        String srcFileName = path + "\\鉴定意见书（初审）.doc";
        if (File.Exists(srcFileName) && !File.Exists(dstFileName))
            File.Copy(srcFileName, dstFileName);

        dstFileName = path + "\\成型照片（复审）.doc";
        srcFileName = path + "\\成型照片（初审）.doc";
        if (File.Exists(srcFileName) && !File.Exists(dstFileName))
            File.Copy(srcFileName, dstFileName);

        return "000";
    }

    [WebMethod]
    public String CopyFinal(String reportNo)
    {
        String path = ConfigurationManager.AppSettings["reportDir"] + "\\" + reportNo;

        String dstFileName = path + "\\鉴定意见书.doc";
        String srcFileName = path + "\\鉴定意见书（复审）.doc";
        if (File.Exists(srcFileName) && !File.Exists(dstFileName))
            File.Copy(srcFileName, dstFileName);

        dstFileName = path + "\\成型照片.doc";
        srcFileName = path + "\\成型照片（复审）.doc";
        if (File.Exists(srcFileName) && !File.Exists(dstFileName))
            File.Copy(srcFileName, dstFileName);

        return "000";
    }

    [WebMethod]
    public String ReSetNo(String can,String san,String shang,String jing)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "UPDATE 参数表 SET 参数值 = " + can + " WHERE 组名 = '初始编号' AND 参数ID = 0;";
        sql += "UPDATE 参数表 SET 参数值 = " + san + " WHERE 组名 = '初始编号' AND 参数ID = 1;";
        sql += "UPDATE 参数表 SET 参数值 = " + shang + " WHERE 组名 = '初始编号' AND 参数ID = 2;";
        sql += "UPDATE 参数表 SET 参数值 = " + jing + " WHERE 组名 = '初始编号' AND 参数ID = 3;";
        //sql += "DELETE FROM 报告信息;";
        //sql += "DELETE FROM 跟踪反馈;";

        clsGetData.ExcuteNoQuery(sql);

        return "000";
    }

    //[WebMethod]
    //public Int32 GetNewYear()
    //{
    //    ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

    //    String sql = "SELECT 参数值 FROM 参数表 WHERE 组名 = '年度'";
    //    Int32 year = Convert.ToInt32(clsGetData.GetValue(sql));

    //    return year;
    //}

    [WebMethod]
    public Int32 GetNewID(String group,String year)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "SELECT MAX(编号) AS MAXID FROM 报告信息 WHERE 年度 = '" + year + "' AND 类别 = " + group + "  GROUP BY 年度,类别";
        Int32 curMaxID = Convert.ToInt32(clsGetData.GetValue(sql)) + 1;

        sql = "SELECT 参数值 AS MAXID FROM 参数表 WHERE 参数ID = " + group + " AND 组名 = '初始编号'";
        Int32 beginID = Convert.ToInt32(clsGetData.GetValue(sql));

        return Math.Max(beginID, curMaxID);
    }

    [WebMethod]
    public Int32 SubmitCase1(String group, String submitSQL,String year)
    {
        Int32 maxID = GetNewID(group, year);

        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = submitSQL.Replace("/NO/", maxID.ToString());

        clsGetData.SetTable(sql);

        return maxID;
    }

    [WebMethod]
    public Int32 SubmitCase2(String id, String submitSQL)
    {
        Int32 maxID = Convert.ToInt32(id);

        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = submitSQL.Replace("/NO/", maxID.ToString());

        clsGetData.SetTable(sql);

        return maxID;
    }

    [WebMethod]
    public String RenoReport(String oldNo, String newNo)
    {
        String root = ConfigurationManager.AppSettings["reportDir"] + "\\";
        
		try
		{
			Directory.Move(root + oldNo,root + newNo); 
		}
		catch(Exception ex)
		{
			return ex.ToString();
		}
        
        return "000";
    }
    
    [WebMethod]
    public String SendMail()
    {
        SmtpClient smtp = new SmtpClient(); //实例化一个SmtpClient

        smtp.DeliveryMethod = SmtpDeliveryMethod.Network; //将smtp的出站方式设为 Network

        smtp.EnableSsl = false;//smtp服务器是否启用SSL加密

        smtp.Host = "smtp.163.com"; //指定 smtp 服务器地址

        smtp.Port = 25;             //指定 smtp 服务器的端口，默认是25，如果采用默认端口，可省去

        //如果你的SMTP服务器不需要身份认证，则使用下面的方式，不过，目前基本没有不需要认证的了

        //smtp.UseDefaultCredentials = true;

        //如果需要认证，则用下面的方式

        smtp.Credentials = new NetworkCredential("judicialims@163.com", "P@ssw0rd");

        MailMessage mm = new MailMessage(); //实例化一个邮件类

        mm.Priority = MailPriority.Normal; //邮件的优先级，分为 Low, Normal, High，通常用 Normal即可

        mm.From = new MailAddress("judicialims@163.com", "上海司法鉴定信息管理系统", Encoding.UTF8);

        mm.To.Add("49096095@qq.com");

        mm.Subject = "开发反馈"; //邮件标题

        mm.SubjectEncoding = Encoding.UTF8;// .GetEncoding(936);

        mm.IsBodyHtml = false; //邮件正文是否是HTML格式
        
        mm.BodyEncoding = Encoding.UTF8;// .GetEncoding(936);

        mm.Body = "上海司法鉴定信息管理系统开发反馈";

        //邮件正文

        String path = Server.MapPath("App_Data");
        if (Directory.Exists(path))
        {
            mm.Attachments.Add(new Attachment(path + "\\Data.mdb"));
        }
        
        try
        {
            smtp.Send(mm); //发送邮件，如果不返回异常， 则大功告成了。
        }
        catch (Exception e)
        {
            return "001|" + e.Message;
        }

        return "000";
    }

    [WebMethod]
    public String BackReport(String year,String month,String type,String reprortNo)
    {
        DirectorySecurity ds = new DirectorySecurity();
        ds.AddAccessRule(new FileSystemAccessRule("Everyone", FileSystemRights.FullControl, InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, PropagationFlags.None, AccessControlType.Allow));
        ds.AddAccessRule(new FileSystemAccessRule("NETWORK SERVICE", FileSystemRights.FullControl, InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, PropagationFlags.None, AccessControlType.Allow));
       
        
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        String sql = "SELECT 参数值 FROM 视图_类型组别 WHERE 参数ID = " + type;
        String group = clsGetData.GetValue(sql).ToString();


        String backPath = Server.MapPath("Backup");
        String reportPath = ConfigurationManager.AppSettings["reportDir"];
        String pathTemp = "";
        String fileName = "";


        if (reprortNo != "")
        {
            pathTemp = backPath + "\\沪枫林 " + year + " " + group + " " + getSubNo(reprortNo, 0) + "号";
            fileName = backPath + "\\沪枫林 " + year + " " + group + " " + getSubNo(reprortNo, 0) + "号" + ".zip";
            sql = "SELECT * FROM 报告信息 WHERE Year(受理日期) = " + year + " AND 类别 = " + type + " AND 编号 = " + getSubNo(reprortNo, 0) + " AND 次级编号 = 0";
        }
        else
        {
            String m = (int.Parse(month) > 9) ? month : int.Parse(month).ToString("00");
            pathTemp = backPath + "\\沪枫林 " + year + "-" + m + " " + group;
            fileName = backPath + "\\沪枫林 " + year + "-" + m + " " + group + ".zip";
            sql = "SELECT * FROM 报告信息 WHERE Year(受理日期) = " + year 
                + " AND Month(受理日期) = " + month 
                + " AND 类别 = " + type + " AND 次级编号 = 0";
        }

        try
        {
            if (!Directory.Exists(backPath))
                Directory.CreateDirectory(backPath);

            if (Directory.Exists(pathTemp))
                Directory.Delete(pathTemp, true);
            Directory.CreateDirectory(pathTemp, ds);

            if (File.Exists(fileName))
                File.Delete(fileName);
        }
        catch(Exception e)
        {
            return "001";
        }

        DataTable result = clsGetData.GetTable(sql);

        foreach (DataRow report in result.Rows)
        {
            String no = report["编号"].ToString();
            String people = report["受检人"].ToString();
            String subNo = getSubNo(no, 0);

            String curDir = reportPath + "\\沪枫林 " + year + " " + group + " " + subNo + " 号";
            if (Directory.Exists(curDir))
            {
                String backDir = pathTemp + "\\" + "沪枫林 " + year + " " + group + " " + subNo + " 号 " + people;

                Directory.CreateDirectory(backDir, ds);
                Directory.CreateDirectory(backDir + "\\初步照片", ds);

                foreach (String fileReport in Directory.GetFiles(curDir))
                {
                    String name = fileReport.Substring(fileReport.LastIndexOf("\\") + 1);
                    String suffix = name.Substring(name.Length - 3);
                    if (suffix.ToUpper() == "DOC")
                        File.Copy(fileReport, backDir + "\\" + name);
                    else
                        File.Copy(fileReport, backDir + "\\初步照片\\" + name);
                }
            }
        }

        ZipFile zip = ZipFile.Create(fileName);
        zip.BeginUpdate();

        DirectoryInfo dir = new DirectoryInfo(pathTemp);
        ZipNameTransform zipName = new ZipNameTransform(pathTemp);
        AddZip(zip,dir,zipName);

        zip.CommitUpdate();
        zip.Close();

        Directory.Delete(pathTemp, true);

        return "000";
    }

    private void AddZip(ZipFile zip, DirectoryInfo dir,ZipNameTransform zipName)
    {
        FileInfo[] files = dir.GetFiles();

        foreach (FileInfo file in files)
        {
            zip.Add(file.FullName, zipName.TransformFile(file.FullName));
        }
        
        DirectoryInfo[] dirs = dir.GetDirectories();
        foreach (DirectoryInfo srcDir in dirs)
        {
            zip.AddDirectory(zipName.TransformDirectory(srcDir.FullName));
            AddZip(zip, srcDir, zipName);
        }
    }
}
