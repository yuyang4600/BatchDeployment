package Test;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;

import com.jcraft.jsch.ChannelExec;
import com.jcraft.jsch.ChannelSftp;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;
import com.jcraft.jsch.SftpException;

import Reader.FReader;
import Reader.Reader;
import SSH.SSHConn;

public class test05 {

	@SuppressWarnings("deprecation")
	public static void main(String[] args) throws JSchException, IOException, SftpException {
		// TODO Auto-generated method stub
		Reader reader=new Reader("C:\\Users\\Macbook Pro\\Desktop\\del_aml1.xlsx");
		reader.read();
		Map<String,String> map=reader.getMap();
		//Tomcat路径
		String remoteTomcat="/home/amlweb/apache-tomcat-6.0.10/";
		//web路径
		String webLocation=remoteTomcat+"webapps/";
		//bin路径
		String binLocation=remoteTomcat+"bin/";
		//tar路径
		String tarLocation="C:\\usr\\";
		String tarName="aml.zip";
		//系统名称
		String programName="aml";
		String env_sh="source ~/.bash_profile;";
		for(Iterator it=map.keySet().iterator();it.hasNext();){
			try {
			String key=(String) it.next();
			String url=map.get(key);
			System.out.println(key+" "+url);			
		    Session session=SSHConn.getSession(
		    		url.substring(url.indexOf("|")+1,url.lastIndexOf("|")),
		    		url.substring(0, url.indexOf("|")),
		    		url.substring(url.lastIndexOf("|")+1));
		    String ls="ps -ef|grep java|grep -v grep|grep tomcat|grep "+programName+"|awk '{print $2}'";
		    String s=SSHConn.exec(session, env_sh+ls);
		    String[] ss=s.split(",");
		   
		    for(String s1:ss){
		    	if(s1.length()>0)
		    		SSHConn.exec(session, env_sh+"kill -9 "+s1);
		    };
	
		     ls="tar -zcvf "+webLocation+programName+new SimpleDateFormat("yyyyMMdd").format(new Date())+".tar"+" "
		              +webLocation+programName;
		    SSHConn.exec(session, env_sh+ls);
		    SSHConn.getFtp(session, tarLocation+tarName, webLocation);
		    if(tarName.endsWith(".tar")){
		        ls="tar -zxvf "+tarName+" -C "+webLocation;}
		    if(tarName.endsWith(".zip")){
		    	ls="unzip -u -o "+webLocation+tarName+" -d "+webLocation;}
		    
		    SSHConn.exec(session, env_sh+ls);
		    SSHConn.exec(session, env_sh+"sh "+binLocation+"startup.sh");
			}
			catch(JSchException e){
				throw new RuntimeException(e);
			}
		}
		
		System.exit(0);
	}

}
