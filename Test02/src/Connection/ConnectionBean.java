package Connection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConnectionBean {
	private String userName="";
	private String passWord="";
    public  Connection getConnection(String url) throws ClassNotFoundException, SQLException{
    	Class.forName("oracle.jdbc.driver.OracleDriver");    	
    	return DriverManager.getConnection(url, userName, passWord);
    }
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getPassWord() {
		return passWord;
	}
	public void setPassWord(String passWord) {
		this.passWord = passWord;
	}
    
}
