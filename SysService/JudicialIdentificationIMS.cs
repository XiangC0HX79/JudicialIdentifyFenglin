using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.InteropServices;
using System.ServiceProcess;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using CommonUtility;

namespace JudicialIdentificationIMS
{
    public partial class JudicialIdentificationIMS : ServiceBase
    {
        private TcpAsyncServer _tcpAsyncServer;

        private Dictionary<TcpAsyncServer.SockWrapper,SocketFile> _socketFileList;

        public JudicialIdentificationIMS()
        {
            InitializeComponent();
        }
               
        private void tcpAsynServer_Connected(Object sender, ref TcpAsyncServer.SockWrapper sockWrapper)
        {
            try
            {
                WriteStr(sockWrapper.Client.RemoteEndPoint + "连接");

                _socketFileList.Add(sockWrapper, new SocketFile() { SockWrapper = sockWrapper });
            }
            catch (Exception ex)
            {
                WriteStr("tcpAsynServer_Connected:" + ex.Message);
            }
        }

        void _tcpAsyncServer_Disconnected(object sender, ref TcpAsyncServer.SockWrapper sockWrapper)
        {
            try
            {
                _socketFileList.Remove(sockWrapper);
            }
            catch (Exception ex)
            {
                WriteStr("_tcpAsyncServer_Disconnected:" + ex.Message);
            }
        }
               
        private void tcpAsynServer_DataReceived(Object sender, ref TcpAsyncServer.SockWrapper sockWrapper,
            ref byte[] bContent, int iCount)
        {
                var bRecv = new byte[iCount];
                Array.Copy(bContent, bRecv, iCount);

            if (iCount == 23)
            {
                var sRecv = Encoding.UTF8.GetString(bRecv);

                if (sRecv != "<policy-file-request/>\0") return;

                const string xml =
                    "<?xml version=\"1.0\"?><cross-domain-policy><site-control permitted-cross-domain-policies=\"all\"/><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>\0";

                var bSend = Encoding.UTF8.GetBytes(xml);

                _tcpAsyncServer._SendOne(sockWrapper, bSend, bSend.Length);

                _tcpAsyncServer.RemoveConnection(sockWrapper);
            }
            else
            {
                try
                {
                    var socketFile = _socketFileList[sockWrapper];

                    if (socketFile.FileSize == 0)
                    {
                        socketFile.NewFile(bRecv);
                    }
                    else if (socketFile.FileSize > (iCount + socketFile.FileData.Length))
                    {
                        socketFile.FileData.Write(bRecv, 0, bRecv.Length);
                    }
                    else
                    {
                        var len = Convert.ToInt16(socketFile.FileSize - socketFile.FileData.Length);
                        socketFile.FileData.Write(bRecv, 0, len);
                        socketFile.FielSave();

                        if (len >= iCount) return;

                        var bTemp = new byte[iCount - len];
                        Array.Copy(bRecv, len, bTemp, 0, bTemp.Length);
                        socketFile.NewFile(bTemp);
                    }
                }
                catch (Exception ex)
                {
                    WriteStr("Ex:" + ex.Message);

                    var bSend = Encoding.UTF8.GetBytes("FAILED@");
                    _tcpAsyncServer._SendOne(sockWrapper, bSend, bSend.Length);
                }
            }
        }

        public void WriteStr(string str)
        {
            var dout = new StreamWriter(AppDomain.CurrentDomain.BaseDirectory + "ServiceLog" + DateTime.Now.ToString("yyyy-MM-dd") + ".txt",true);
            dout.Write(DateTime.Now.ToString("HH:mm:ss") + "  " + str + "\r\n");
            dout.Close();
        }

        protected override void OnStart(string[] args)
        {
            WriteStr("服务启动");

            try
            {
                var streamReader = new StreamReader(AppDomain.CurrentDomain.BaseDirectory + "JudicialIdentificationIMS.cfg",Encoding.UTF8);

                var lport = "12306";
                var lip = "127.0.0.1";

                var reportDir = "";

                for (var line = streamReader.ReadLine(); line != null; line = streamReader.ReadLine())
                {
                    var regex = new Regex(@"\s+", RegexOptions.Singleline);
                    var lineTrim = regex.Replace(line, "").ToUpper();

                    if (lineTrim.IndexOf("LOCAL_PORT=", StringComparison.Ordinal) >= 0)
                        lport = lineTrim.Substring("LOCAL_PORT=".Length);
                    else if (lineTrim.IndexOf("LOCAL_IP=", StringComparison.Ordinal) >= 0)
                        lip = lineTrim.Substring("LOCAL_IP=".Length);
                    else if (lineTrim.IndexOf("REPORT_DIR=", StringComparison.Ordinal) >= 0)
                        reportDir = lineTrim.Substring("REPORT_DIR=".Length);
                }

                _tcpAsyncServer = new TcpAsyncServer(Convert.ToInt32(lport), IPAddress.Parse(lip));
                _tcpAsyncServer.DataReceived += tcpAsynServer_DataReceived;
                _tcpAsyncServer.Connected += tcpAsynServer_Connected;
                _tcpAsyncServer.Disconnected += _tcpAsyncServer_Disconnected;

                SocketFile.ReportDir = reportDir;
                SocketFile.TcpAsyncServer = _tcpAsyncServer;

                _socketFileList = new Dictionary<TcpAsyncServer.SockWrapper, SocketFile>();
            }
            catch (Exception ex)
            {
                WriteStr(ex.Message);
            }
        }

        protected override void OnStop()
        {
        }
    }

    class SocketFile
    {
        public static String ReportDir;
        public static TcpAsyncServer TcpAsyncServer;

        public byte[] BuffHead;
        public String ReportNo;
        public String FileName;
        public UInt32 FileSize;
        public MemoryStream FileData;

        public TcpAsyncServer.SockWrapper SockWrapper;

        public void FielSave()
        {
            var path = ReportDir + "\\" + ReportNo;

            var byteArr = new Byte[FileData.Length];
            FileData.Position = 0;
            FileData.Read(byteArr, 0, byteArr.Length);
                               
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }

            var file = new FileStream(path + "\\" + FileName, FileMode.Create);

            file.Write(byteArr, 0, byteArr.Length);
            file.Flush();
            file.Close();

            WriteStr("FileSave " + FileName);

            var bSend = Encoding.UTF8.GetBytes("SUCCESS@");
            TcpAsyncServer._SendOne(SockWrapper, bSend, bSend.Length);

            FileSize = 0;
            BuffHead = null;
        }

        public void NewFile(byte[] bRecv)
        {
            if (bRecv.Length <= 65)
            {
                BuffHead = new byte[bRecv.Length];
                Array.Copy(bRecv, BuffHead,BuffHead.Length);
                return;
            }

            var ms = new MemoryStream();
            if (BuffHead != null)
            {
                ms.Write(BuffHead, 0, BuffHead.Length);
            }
            ms.Write(bRecv, 0, bRecv.Length);
            ms.Position = 0;

            var bTemp = new byte[4];
            ms.Read(bTemp, 0, bTemp.Length);
            var lReportNo = BitConverter.ToUInt32(bTemp, 0);

            bTemp = new byte[lReportNo];
            ms.Read(bTemp, 0, bTemp.Length);
            ReportNo = Encoding.UTF8.GetString(bTemp);

            bTemp = new byte[4];
            ms.Read(bTemp, 0, bTemp.Length);
            var lFilename = BitConverter.ToUInt32(bTemp, 0);

            bTemp = new byte[lFilename];
            ms.Read(bTemp, 0, bTemp.Length);
            FileName = Encoding.UTF8.GetString(bTemp);

            bTemp = new byte[4];
            ms.Read(bTemp, 0, bTemp.Length);
            FileSize = BitConverter.ToUInt32(bTemp, 0);

            var len = ms.Length - ms.Position;
            if (FileSize > len)
            {
                bTemp = new byte[len];
                ms.Read(bTemp, 0, bTemp.Length);

                FileData = new MemoryStream();
                FileData.Write(bTemp, 0, bTemp.Length);
            }
            else
            {
                bTemp = new byte[FileSize];
                ms.Read(bTemp, 0, bTemp.Length);

                FileData = new MemoryStream();
                FileData.Write(bTemp, 0, bTemp.Length);

                FielSave();

                if (FileSize >= len) return;

                bTemp = new byte[ms.Length - ms.Position];
                ms.Read(bTemp, 0, bTemp.Length);
                NewFile(bTemp);
            }
        }

        public void WriteStr(string str)
        {
            var dout = new StreamWriter(AppDomain.CurrentDomain.BaseDirectory + "ServiceLog" + DateTime.Now.ToString("yyyy-MM-dd") + ".txt", true);
            dout.Write(DateTime.Now.ToString("HH:mm:ss") + "  " + str + "\r\n");
            dout.Close();
        }
    }
}
