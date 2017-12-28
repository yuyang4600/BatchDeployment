package SSH;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Properties;

import com.jcraft.jsch.Channel;
import com.jcraft.jsch.ChannelExec;
import com.jcraft.jsch.ChannelSftp;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;
import com.jcraft.jsch.SftpException;

public class SSHConn {
	public static Session getSession(String user,String ip,String password) throws JSchException{
		JSch jsch = new JSch();
		Session session=jsch.getSession(user, ip, 22);
		com.jcraft.jsch.Logger logger = new SettleLogger();
        JSch.setLogger(logger);
		session.setPassword(password);
		Properties config = new Properties();
        config.put("StrictHostKeyChecking", "no");
        config.put("userauth.gssapi-with-mic", "no");
        session.setConfig(config); // 为Session对象设置properties
        session.setTimeout(60000); // 设置timeout时间
        session.connect(); // 通过Session建立链接
        return session;
	}
	public static String exec(Session session,String sh) throws JSchException, IOException {		
        ChannelExec channelExec = (ChannelExec) session.openChannel("exec");
      channelExec.setCommand(sh);  
      channelExec.setInputStream(null);  
      channelExec.setErrStream(System.err);  
      channelExec.connect();  
      InputStream in = channelExec.getInputStream();  
      BufferedReader reader = new BufferedReader(new InputStreamReader(in));  
      String buf = null;  
      StringBuffer sb = new StringBuffer();  
      while ((buf = reader.readLine()) != null) {  
          sb.append(buf).append(",");
          System.out.println(buf);
      }  
      reader.close();  
      int i=channelExec.getExitStatus();
      System.out.println( sh);
      System.out.println(i);
      if(i!=0){
    	  throw new JSchException();
      }
      channelExec.disconnect();  
      
      return sb.toString();
	}
	public static void getFtp(Session session,String tar,String Target) throws JSchException, IOException, SftpException {		
        ChannelSftp channelSftp = (ChannelSftp) session.openChannel("sftp");  
        channelSftp.connect();
        channelSftp.put(tar, Target);
        channelSftp.disconnect();
	}

}
