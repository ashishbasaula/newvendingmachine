package com.wsm.comlib.constant;

import android.annotation.SuppressLint;
import android.content.ContentValues;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PorterDuff.Mode;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

@SuppressWarnings("deprecation")
@SuppressLint({ "SimpleDateFormat", "DefaultLocale" })
public class CommonUtil {
	private static final String DEFAULT_DATE_PATTEN = "yyyy-MM-dd HH:mm:ss";
	public static final String PROMOTION_PARAM_DATE_PATTEN = "yyyy-MM-dd HH:mm";
	public static String PROMOTION_DISPLAY_DATE_PATTEN = "yyyy年MM月dd日  HH:mm";
	public static String mDatePatten = "yyyy年MM月dd日";
	public static final String RESERVE_TIME_DISPLAY_PATTEN = "yyyy-MM-dd HH:mm";
	
	public static String getDateStr(Calendar calendar, String pattern){
		return getDateStr(calendar.getTime(), pattern);
	}
	public static String getDateStr(Calendar date){
		return getDateStr(date.getTime(),DEFAULT_DATE_PATTEN);
	}
	
	
	public static String getDateStr(Date date){
		return getDateStr(date,DEFAULT_DATE_PATTEN);
	}
	
	public static Date parseDate(String str){
		return parseDate(str, DEFAULT_DATE_PATTEN);
	}
	
	
	public static String getDateStr(Date date, String pattern){
		if(date == null || TextUtils.isEmpty(pattern)){
			return null;
		}
		SimpleDateFormat df = new SimpleDateFormat(pattern);
		return df.format(date);
	}
	
	public static Date parseDate(String str, String pattern){
		if(TextUtils.isEmpty(str) || TextUtils.isEmpty(pattern)){
			return null;
		}
		SimpleDateFormat df = new SimpleDateFormat(pattern);
		try {
			return df.parse(str);
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}
	// Get round corner bitmap.
	public static Bitmap getRoundedCornerBitmap(Bitmap bitmap, int pixels) {
		Bitmap output = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), Config.ARGB_8888);
		Canvas canvas = new Canvas(output);
		final int color = 0xff424242;
		final Paint paint = new Paint();
		final Rect rect = new Rect(0, 0, bitmap.getWidth(), bitmap.getWidth());
		final RectF rectF = new RectF(rect);
		final float roundPx = pixels;
		paint.setAntiAlias(true);
		canvas.drawARGB(0, 0, 0, 0);
		paint.setColor(color);
		canvas.drawRoundRect(rectF, roundPx, roundPx, paint);
		paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
		canvas.drawBitmap(bitmap, rect, rect, paint);
		return output;
	}
	
	public static Bitmap getCircleBitmapWithBorder(Bitmap bitmap, int pixels) {
		Bitmap output = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), Config.ARGB_8888);
		Canvas canvas = new Canvas(output);
		final int color = 0xffffffff;
		final Paint paint = new Paint();
		int srcW = bitmap.getWidth();
		int srcH = bitmap.getHeight();
		int desW = Math.min(srcW, srcH);
		final float roundPx = desW/2;
		final Rect src = new Rect(0, 0, srcW, srcH);
		Rect des = null;
		if (srcW > srcH) {
			int left = (srcW-desW)/2;
			des = new Rect(left , 0, left+desW, srcH);
		}else{
			int top = (srcH-desW)/2;
			des = new Rect(0 , top, srcW, top+desW);
		}
		paint.setAntiAlias(true);
		canvas.drawARGB(0, 0, 0, 0);
		paint.setColor(color);
		canvas.drawCircle(srcW/2,srcH/2,roundPx, paint);//图片中心点画�?
		paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
		final Paint imagePaint = new Paint();
		imagePaint.setColor(0xffffffff);
		canvas.drawBitmap(bitmap, src, des, paint);
		return output;
	}
	// Get round corner bitmap.
		public static Bitmap getCircleBitmap(Bitmap bitmap, int pixels) {
			Bitmap output = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), Config.ARGB_8888);
			Canvas canvas = new Canvas(output);
			final int color = 0xff424242;
			final Paint paint = new Paint();
			int srcW = bitmap.getWidth();
			int srcH = bitmap.getHeight();
			int desW = Math.min(srcW, srcH);
			final float roundPx = desW/2;
			final Rect src = new Rect(0, 0, srcW, srcH);
			Rect des = null;
			if (srcW > srcH) {
				int left = (srcW-desW)/2;
				des = new Rect(left , 0, left+desW, srcH);
			}else{
				int top = (srcH-desW)/2;
				des = new Rect(0 , top, srcW, top+desW);
			}
			paint.setAntiAlias(true);
			canvas.drawARGB(0, 0, 0, 0);
			paint.setColor(color);
			canvas.drawCircle(srcW/2,srcH/2,roundPx, paint);//图片中心点画�?
			paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
			canvas.drawBitmap(bitmap, src, des, paint);
			return output;
		}
	static public void checkDeviceCode() {
		String defaultCharsetName = Charset.defaultCharset().displayName();
	}
	
	public static boolean hasSdCard() {
		String sdStatus = Environment.getExternalStorageState();
		if (!sdStatus.equals(Environment.MEDIA_MOUNTED)) { // �?��sd是否可用
			return false;
		}
		return true;
	}

	public static String getSdCardPath() {
		String sdPath = "";
		if (hasSdCard()) {
			sdPath = Environment.getExternalStorageDirectory().toString();
		}
		return sdPath;
	}
	
	public static String getPackageName(Context context) {
		String packageName = "";
		packageName = context.getPackageName();
		return packageName;
	}
	


	public static String vedioCacheDir() {
		File file = new File(getSdCardPath()+"/tstudySdk/vedio");
		try {
			if (!file.exists()) {
				boolean result = file.mkdir();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return file.getPath();
	}
	
	public static String imageCacheDir() {
		File file = new File(getSdCardPath()+"/tstudySdk/image");
		try {
			if (!file.exists()) {
				boolean result = file.mkdir();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return file.getPath();
	}
	
	/**
	 * 添加视频去图库
	 */
	public static void addVedioToGallery(String filePath){
		ContentValues values = new ContentValues(3);
	    values.put(MediaStore.Video.Media.TITLE, "tstudySdk");
	    values.put(MediaStore.Video.Media.MIME_TYPE, "video/mp4");
	    values.put(MediaStore.Video.Media.DATA, filePath);
	}


	/**
	 * drawable to Bitmap
	 * @param drawable
	 * @return
	 */
	public static Bitmap drawableToBitmap (Drawable drawable) {
	    if (drawable instanceof BitmapDrawable) {
	        return ((BitmapDrawable)drawable).getBitmap();
	    }
	    Bitmap bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Config.ARGB_8888);
	    Canvas canvas = new Canvas(bitmap);
	    drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
	    drawable.draw(canvas);
	    return bitmap;
	}
	public static boolean checkNull(String str) {
        if (str == null || str.length() == 0){
            return true;
        }
        str = str.trim();
        return str.length()==0;
    }
	
	public static String getIMEI(Context context){
		TelephonyManager TelephonyMgr = (TelephonyManager)context.getSystemService(Context.TELEPHONY_SERVICE);
		String imei = TelephonyMgr.getDeviceId();
		if (TextUtils.isEmpty(imei)) {
			imei = getAndroidId(context);
		}
		return imei;
	}
	
	public static String formatDouble(double value, int length){
		BigDecimal each = new BigDecimal(value);
		each = each.setScale(length, BigDecimal.ROUND_HALF_UP);
		return each.toString();
	}
	
	public static String formatDouble(String value, int length){
		if (value == null) {
			return "0";
		}
		BigDecimal each = new BigDecimal(value);
		each = each.setScale(length, BigDecimal.ROUND_HALF_UP);
		return each.toString();
	}
	
	// 获取ApiKey
    public static String getMetaValue(Context context, String metaKey) {
        Bundle metaData = null;
        String apiKey = null;
        if (context == null || metaKey == null) {
            return null;
        }
        try {
            ApplicationInfo ai = context.getPackageManager()
                    .getApplicationInfo(context.getPackageName(),
                            PackageManager.GET_META_DATA);
            if (null != ai) {
                metaData = ai.metaData;
            }
            if (null != metaData) {
                apiKey = metaData.getString(metaKey);
            }
        } catch (NameNotFoundException e) {

        }
        return apiKey;
    }

	public static String getVersion(Context context){//获取版本号
		try {  
            PackageInfo pi=context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
            return pi.versionName;  
        } catch (NameNotFoundException e) {
            e.printStackTrace();
            return null;
        }  
    }  
 
	public static int getVersionCode(Context context) {  //获取版本号(内部识别号)
	    try {  
	        PackageInfo pi=context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
	        return pi.versionCode;  
	    } catch (NameNotFoundException e) {
	        e.printStackTrace();
	        return 0;  
	    }  
	}  
	public static String getAndroidId(Context context) {
		return android.provider.Settings.Secure.getString(
		context.getContentResolver(),
		android.provider.Settings.Secure.ANDROID_ID);
	}

	public static Bitmap resizeImage(Bitmap bitmap, int reqWidth, int reqHeight){
		if (bitmap == null) {
			return null;
		}
        int width = bitmap.getWidth();  
        int height = bitmap.getHeight();  
        float scaleWidth = 0;
        float scaleHeight = 0;
        Matrix matrix = new Matrix();
		scaleWidth = ((float) reqWidth) / width;  
	    scaleHeight = ((float) reqHeight) / height; 
        matrix.postScale(scaleWidth, scaleHeight);  
        Bitmap resizedBitmap = Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
        return resizedBitmap;  
    }
	
	public static Bitmap cropImage(Bitmap bitmap, int reqWidth, int reqHeight){
		if (bitmap == null) {
			return null;
		}
        int width = bitmap.getWidth();  
        int height = bitmap.getHeight();  
        if (reqWidth >= width || reqHeight >= height) {
			return bitmap;
		}
//        float scaleWidth = 0;
//        float scaleHeight = 0;
//        Matrix matrix = new Matrix();  
//        if (reqWidth > width) {
//        	scaleWidth = ((float) reqWidth) / width;  
//		}
//        if (reqHeight > height) {
//        	scaleHeight = ((float) reqHeight) / height; 
//		}
//        matrix.postScale(scaleWidth, scaleHeight);  
        int x = width/2 - reqWidth/2;
        int y = height/2 - reqHeight/2;
        Bitmap resizedBitmap = Bitmap.createBitmap(bitmap, x, y, reqWidth, reqHeight, null, true);
        return resizedBitmap;  
    }
	
	public static String saveImage(Bitmap bmp) {
		if (bmp == null) {
			return null;
		}
	    // 首先保存图片
	    String fileName = System.currentTimeMillis() + ".jpg";
	    File file = new File(imageCacheDir(),fileName);
	    try {
	        FileOutputStream fos = new FileOutputStream(file);
	        bmp.compress(CompressFormat.JPEG,60, fos);
	    } catch (FileNotFoundException e) {
	        e.printStackTrace();
	    }
	    return file.getAbsolutePath();
	}
	
}
