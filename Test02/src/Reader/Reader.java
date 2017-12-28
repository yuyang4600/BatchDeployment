package Reader;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class Reader {
    private Map<String,String> map=new HashMap<String,String>();
    private File f;
    public Reader(String location){
    	f=new File(location);
    	System.out.println(f);
    }
    public void read() throws IOException{
    	FileInputStream in=new FileInputStream(f);
    	XSSFWorkbook book=new XSSFWorkbook(in);
    	in.close();
    	XSSFSheet sheet=book.getSheetAt(0);
    	System.out.println(sheet.getSheetName());
    	System.out.println(sheet.getLastRowNum());
    	for (int row=1;row<sheet.getLastRowNum();row++){  
    		XSSFRow rows =sheet.getRow(row);
    		if(rows==null)
    			return;
    		map.put(sheet.getRow(row).getCell(0).getStringCellValue(), 
    				sheet.getRow(row).getCell(1).getStringCellValue()+"|"+
    				sheet.getRow(row).getCell(2).getStringCellValue()+"|"+
    	    		sheet.getRow(row).getCell(3).getStringCellValue());
    	}
    }
    public Map getMap() throws IOException{
    	return map;
    }
}
