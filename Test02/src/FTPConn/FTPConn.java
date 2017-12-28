package FTPConn;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.SocketException;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;


public class FTPConn {
    public static boolean uploadFile(File f,String url,String path) throws SocketException, IOException{
    	boolean success=false;
    	FTPClient client=new FTPClient(); 	
    	client.enterLocalActiveMode();
    		client.connect(url,21);
    		client.login("amlserver", "amlserver");
    		
    		System.out.println(client.getReply());
    		if(!FTPReply.isPositiveCompletion(client.getReply())){
    			client.disconnect();
    			return success;
    		}
    		client.changeWorkingDirectory(path);
    		client.setFileType(FTPClient.BINARY_FILE_TYPE);
    		client.storeFile(f.getName(), new FileInputStream(f));
    		success=true; 	
    		client.disconnect();
    		return success;   	
    }
    public static File getFile(String url,String path,String name) throws IOException{
    	FTPClient client=new FTPClient();    	
    		client.connect(url);
    		client.login("amlserver", "amlserver");
    		if(!FTPReply.isPositiveCompletion(client.getReply())){
    			client.disconnect();
    			System.out.println("¡¥Ω” ß∞‹");
    		}
    		client.changeWorkingDirectory(path);
    		client.setFileType(FTPClient.BINARY_FILE_TYPE);
    		InputStream in=client.retrieveFileStream(name);
    		BufferedReader br = new BufferedReader(new InputStreamReader(in));  
            String data = null; 
            StringBuffer resultBuffer=null;
    		 while ((data = br.readLine()) != null) {  
                 resultBuffer.append(data + "\n");  
             }
    		 File f=new File(path);
    		BufferedWriter bw = new BufferedWriter(new FileWriter(f, true)); 
    		bw.write(resultBuffer.toString());
    		bw.flush();  
            bw.close(); 
            client.disconnect();
			return f;
    	
    	
    }
}
