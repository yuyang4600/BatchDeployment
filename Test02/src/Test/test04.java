package Test;

import java.io.File;
import java.io.IOException;
import java.net.SocketException;

import FTPConn.FTPConn;

public class test04 {

	public static void main(String[] args) throws SocketException, IOException {
		// TODO Auto-generated method stub
		FTPConn.uploadFile(new File("c:\\test.txt"),"163.1.10.55","/home/amlserver");

	}

}
