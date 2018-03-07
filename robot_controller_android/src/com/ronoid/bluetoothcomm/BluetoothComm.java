package com.ronoid.bluetoothcomm;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class BluetoothComm extends Activity {
    // Debugging
    private static final String TAG = "BluetoothComm";
    private static final boolean D = true;
    //������������requestCode
	static final int REQUEST_ENABLE_BT = 1;
	//�������ӵ�requestCode
	static final int REQUEST_CONNECT_DEVICE = 2;
	//bluetoothCommService ��������Ϣ״̬
    public static final int MESSAGE_STATE_CHANGE = 1;
    public static final int MESSAGE_READ = 2;
    public static final int MESSAGE_WRITE = 3;
    public static final int MESSAGE_DEVICE_NAME = 4;
    public static final int MESSAGE_TOAST = 5;
	
    // Key names received from the BluetoothChatService Handler
    public static final String DEVICE_NAME = "device_name";
    public static final String TOAST = "toast";
    //�����豸
	private BluetoothDevice device = null;
	
	private EditText txEdit;
	private EditText rxEdit;
	private EditText inputEdit;
	//���ӵ��豸
	private TextView connectDevices;
	//���Ͱ���
	private Button sendButton;
	//��ս��ռ�¼����
	private Button clearRxButton;
	//������ͼ�¼����
	private Button clearTxButton;
	//�Ͽ����Ӱ���
	private Button disconnectButton;
	private Button clearAll;
	//��������������
	private Button Forward;
	private Button Back;
	
	private BluetoothAdapter bluetooth;
	//����һ���������ڷ������
	private BluetoothCommService mCommService = null;
	
	private StringBuffer mOutStringBuffer = new StringBuffer("");
	
    private String mConnectedDeviceName = null;
    
    // Array adapter for the conversation thread
    private ArrayAdapter<String> mConversationArrayAdapter;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        //��ÿؼ�
        //����
        sendButton = (Button)findViewById(R.id.sendButton);
        sendButton.setOnClickListener(new btnClickedListener());
        //��շ�������
        clearRxButton = (Button)findViewById(R.id.clearRx);
        clearRxButton.setOnClickListener(new btnClickedListener());
        //��ս�������
        clearTxButton = (Button)findViewById(R.id.clearTx);
        clearTxButton.setOnClickListener(new btnClickedListener());
        //my button
        Forward = (Button)findViewById(R.id.forward);
        Forward.setOnClickListener(new btnClickedListener());
        
        Back = (Button)findViewById(R.id.back);
        Back.setOnClickListener(new btnClickedListener());
        
        disconnectButton = (Button)findViewById(R.id.disconnectButton);
        disconnectButton.setOnClickListener(new btnClickedListener());
        clearAll = (Button)findViewById(R.id.clearALL);
        clearAll.setOnClickListener(new btnClickedListener());
        txEdit = (EditText)findViewById(R.id.tx_history);
        rxEdit = (EditText)findViewById(R.id.rx_history);
        inputEdit = (EditText)findViewById(R.id.inputEdit);
        connectDevices = (TextView)findViewById(R.id.connected_device);
        //��ñ��������豸
        bluetooth = BluetoothAdapter.getDefaultAdapter();
        if(bluetooth == null){//�豸û�������豸
        	Toast.makeText(this, "û���ҵ�����������", Toast.LENGTH_LONG).show();
        	finish();
        	return;
        } 
    }
    
    @Override
	protected void onStart() {
		super.onStart();
    	if(!bluetooth.isEnabled()){
    		//����������豸
    		Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
    		startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
    	} else {
    		if(mCommService==null) {
    			mCommService = new BluetoothCommService(this, mHandler);
    		}
    	}
	}

	@Override
	protected synchronized void onResume() {
		super.onResume();
        if (mCommService != null) {
            // Only if the state is STATE_NONE, do we know that we haven't started already
            if (mCommService.getState() == BluetoothCommService.STATE_NONE) {
              // Start the Bluetooth services�����������߳�
            	mCommService.start();
            }
        }
	}
    
    @Override
    public synchronized void onPause() {
        super.onPause();
        if(D) Log.e(TAG, "- ON PAUSE -");
    }

    @Override
    public void onStop() {
        super.onStop();
        if(bluetooth!=null){
        	bluetooth.disable();
        }
        if(D) Log.e(TAG, "-- ON STOP --");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        // Stop the Bluetooth chat services
        if (mCommService != null) mCommService.stop();
        if(D) Log.e(TAG, "--- ON DESTROY ---");
    }

	/**
     * onActivityResult������������startActivityForResult����֮����ã�
     * �����û��Ĳ�����ִ����Ӧ�Ĳ���
     */
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
		 switch (requestCode) {
		 case REQUEST_ENABLE_BT:
	            if (resultCode == Activity.RESULT_OK) {
	            	if(D) Log.d(TAG, "�������豸");
	            	Toast.makeText(this, "�ɹ�������", Toast.LENGTH_SHORT).show();    
	            } else {    
	            	if(D) Log.d(TAG, "������������豸");
	                Toast.makeText(this, "���ܴ�����,���򼴽��ر�", Toast.LENGTH_SHORT).show();
	                finish();//�û������豸���������
	            }break;
		 case REQUEST_CONNECT_DEVICE:
			 // When DeviceListActivity returns with a device to connect
	            if (resultCode == Activity.RESULT_OK) {//�û�ѡ�����ӵ��豸
	                // Get the device MAC address
	                String address = data.getExtras()
	                                     .getString(ScanDeviceActivity.EXTRA_DEVICE_ADDRESS);
	                // Get the BLuetoothDevice object
	                device = bluetooth.getRemoteDevice(address);
	                //���������豸
	                mCommService.connect(device);
	            }
	            break;		 
		 }
		 return;
	 }
    
    private class btnClickedListener implements OnClickListener{

		@Override
		public void onClick(View v) {
			if(v.getId() == R.id.sendButton) {
				if(device == null){
					Toast.makeText(BluetoothComm.this, "�������豸��", Toast.LENGTH_LONG).show();
					inputEdit.setText("");
				}
				else {
					String txString = inputEdit.getText()+"";
					//inputEdit.setText("");
					txEdit.append(txString);
					sendMessage(txString);
				}
			} else if(v.getId() == R.id.clearRx){
				rxEdit.setText("");
			} else if(v.getId() == R.id.clearTx){
				txEdit.setText("");
			} else if(v.getId() == R.id.disconnectButton){
				if(mCommService!=null){
					mCommService.stop();
				}
			} else if(v.getId() ==R.id.clearALL){
				inputEdit.setText("");
			} else if(v.getId() ==R.id.forward){
				String control = "1";
				txEdit.append(control);
				sendMessage(control);
			} else if(v.getId() ==R.id.back){
				String control = "2";
				txEdit.append(control);
				sendMessage(control);
			}
		}
    }
    
    private void ensureDiscoverable() {
        if (bluetooth.getScanMode() !=
            BluetoothAdapter.SCAN_MODE_CONNECTABLE_DISCOVERABLE) {
            Intent discoverableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
            //��ɼ�ʱ��Ϊ300s
            discoverableIntent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 300);
            startActivity(discoverableIntent);
        }
    }
    
    //�����˵�ѡ��
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.option_menu, menu);
		return true;
	}

	//�˵�����
	@Override
	public boolean onMenuItemSelected(int featureId, MenuItem item) {
		 switch (item.getItemId()) {
	        case R.id.scan:
	        	 // Launch the ScanDeviceActivity to see devices and do scan
	            Intent serverIntent = new Intent(this, ScanDeviceActivity.class);
	            startActivityForResult(serverIntent, REQUEST_CONNECT_DEVICE);
	            return true;
	        case R.id.discoverable:
	        	ensureDiscoverable();
	            return true;
	        case R.id.about:
	        	Intent intent = new Intent(BluetoothComm.this, AboutActivity.class);
	        	startActivity(intent);
	        	return true;
	        case R.id.exit:
	        	finish();
	        	return true;
	        }
		return false;
	}
    
	 /**
     * Sends a message.
     * @param message  A string of text to send.
     */
    private void sendMessage(String message) {
        //û�������豸�����ܷ���
        if (mCommService.getState() != BluetoothCommService.STATE_CONNECTED) {
            Toast.makeText(this, R.string.nodevice, Toast.LENGTH_SHORT).show();
            return;
        }
		
        // Check that there's actually something to send
        if (message.length() > 0) {
            // Get the message bytes and tell the BluetoothChatService to write
            byte[] send = message.getBytes();
            mCommService.write(send);

            // Reset out string buffer to zero and clear the edit text field
            mOutStringBuffer.setLength(0);
        }
    }

    // The Handler that gets information back from the BluetoothChatService
    private final Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
            case MESSAGE_STATE_CHANGE:
                if(D) Log.i(TAG, "MESSAGE_STATE_CHANGE: " + msg.arg1);
                switch (msg.arg1) {
                case BluetoothCommService.STATE_CONNECTED:
                	connectDevices.setText(R.string.title_connected_to);
                	connectDevices.append(mConnectedDeviceName);
                //    mConversationArrayAdapter.clear();
                    break;
                case BluetoothCommService.STATE_CONNECTING:
                	connectDevices.setText(R.string.title_connecting);
                    break;
                case BluetoothCommService.STATE_LISTEN:
                case BluetoothCommService.STATE_NONE:
                	connectDevices.setText(R.string.title_not_connected);
                    break;
                }
                break;
            case MESSAGE_WRITE:
                byte[] writeBuf = (byte[]) msg.obj;
                // construct a string from the buffer
              //  String writeMessage = new String(writeBuf);
             //   mConversationArrayAdapter.add("Me:  " + writeMessage);
                break;
            case MESSAGE_READ:
                byte[] readBuf = (byte[]) msg.obj;
                // construct a string from the valid bytes in the buffer
                String readMessage = new String(readBuf, 0, msg.arg1);
            //    mConversationArrayAdapter.add(mConnectedDeviceName+":  " + readMessage);
                rxEdit.append(readMessage);
                break;
            case MESSAGE_DEVICE_NAME:
                // save the connected device's name
                mConnectedDeviceName = msg.getData().getString(DEVICE_NAME);
                Toast.makeText(getApplicationContext(), "Connected to "
                               + mConnectedDeviceName, Toast.LENGTH_SHORT).show();
                break;
            case MESSAGE_TOAST:
                Toast.makeText(getApplicationContext(), msg.getData().getString(TOAST),
                               Toast.LENGTH_SHORT).show();
                break;
            }
        }
    };

}