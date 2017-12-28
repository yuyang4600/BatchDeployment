package Test;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;



import Connection.ConnectionBean;
import Reader.FReader;
import Reader.Reader;

public class test {

	public static void main(String[] args) throws ClassNotFoundException, SQLException, FileNotFoundException, IOException {
		// TODO Auto-generated method stub
		Reader reader=new Reader("C:\\Users\\Macbook Pro\\Desktop\\del_aml.xlsx");
		reader.read();
		Map<String,String> map=reader.getMap();
		FReader fReader=new FReader("C:\\Users\\Macbook Pro\\Desktop\\·¶¾ê¾ê\\ÎÞ¿¨ÎÞ´æÕÛ\\4.sql");
		for(Iterator it=map.keySet().iterator();it.hasNext();){
			String key=(String) it.next();
			String url=map.get(key);
			System.out.println(key+" "+url);	
			ConnectionBean bean=new ConnectionBean();
			bean.setUserName(url.substring(url.indexOf("|")+1,url.lastIndexOf("|")));
			bean.setPassWord(url.substring(url.lastIndexOf("|")+1));
			Connection conn=bean.getConnection(url.substring(0,url.indexOf("|")));	
			conn.setAutoCommit(false);
			try{
			//ScriptRunner  runner=new ScriptRunner (conn,false,false);
			//runner.runScript(new FileReader(new File("C:\\Users\\Macbook Pro\\Desktop\\123456.sql")));
				Statement ps=conn.createStatement();
				String[] s=fReader.read().split(";");
				int i=7;
				for(;i<s.length-1;i++){
					String sql=s[i].trim();
					System.out.println(i+":"+sql);					
					   ps.execute(sql);
					   
				}
			    //System.out.println(conn.createStatement().execute("call Test01(date'2017-09-30')"));		    
			}
			catch(Exception e){
				conn.rollback();
				throw new RuntimeException(e);
			}
			finally{
				conn.commit();
			    conn.close();
			}
		}
	}

}
