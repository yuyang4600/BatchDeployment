package Test;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.jcraft.jsch.ChannelExec;
import com.jcraft.jsch.ChannelShell;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;

import SSH.SSHConn;

public class test06 {

	public static void main(String[] args) throws JSchException, IOException {
		// TODO Auto-generated method stub
		Session session=SSHConn.getSession("amlserver","163.1.10.55","amlserver");
		//Tomcat·��
				String remoteTomcat="/home/amlweb/apache-tomcat-6.0.10/";
				//web·��
				String webLocation=remoteTomcat+"webapps/";
				//bin·��
				String binLocation=remoteTomcat+"bin/";
				//����
				String localLocation="";
				//tar·��
				String tarLocation="";
				//ϵͳ����
				String programName="aml";
	    ChannelShell shell=(ChannelShell)session.openChannel("shell");
	    //String ls="tar -cvf "+webLocation+programName+new SimpleDateFormat("yyyyMMdd").format(new Date())+".tar"+" "
	    //          +webLocation+programName;
	    String ls="ps -ef|grep java|grep -v grep|grep tomcat|grep aml|awk '{print $2}'";
	    String env_sh="source ~/.bash_profile;";
	    String s=SSHConn.exec(session, env_sh+ls);
	    String[] ss=s.split(",");
	    for(String s1:ss){
	    	SSHConn.exec(session, env_sh+"kill -9 "+s1);
	    };
	}

}
