package Reader;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class FReader {
	private File f;
	public FReader(String location){
		f=new File(location);
	}
	public String read() throws IOException{
		String s="";
		BufferedReader brReader =new BufferedReader(new InputStreamReader(new FileInputStream(f)));
		String data=null;
		while((data=brReader.readLine())!=null){
			if(data.length()>0)
			    s=s+data+"\n";
		}	
		return s;
	}

}
