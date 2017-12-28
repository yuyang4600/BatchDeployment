package SSH;

public class SettleLogger implements com.jcraft.jsch.Logger{

	@Override
	public boolean isEnabled(int arg0) {
		return true;
	}

	@Override
	public void log(int arg0, String arg1) {
		// TODO Auto-generated method stub
		System.out.println(arg1);
	}

}
