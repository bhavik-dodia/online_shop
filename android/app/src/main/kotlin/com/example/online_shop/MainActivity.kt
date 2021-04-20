package com.example.online_shop

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.provider.MediaStore
import android.provider.MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.custom.imagepicker"
    private var MY_PERMISSIONS_REQUESTS_CAMERA : Int = 2795
    private var MY_PERMISSIONS_REQUESTS_GALLERY : Int = 1255
    private val CAMERA_CAPTURE_IMAGE_REQUEST_CODE = 103
    private var GALLERY : Int = 101
    private lateinit var imageStoragePath : String
    var channel: MethodChannel? = null

    companion object {
        var pendingHintResult: MethodChannel.Result? = null
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if(call.method == "camera") {
                pendingHintResult = result
                checkPermissionCamera()
            } else if(call.method == "gallery") {
                pendingHintResult = result
                checkPermissionGallery()
            }
            // Note: this method is invoked on the main thread.
            // TODO
        }
    }

    private fun checkPermissionCamera() {
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.CAMERA,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), MY_PERMISSIONS_REQUESTS_CAMERA)
        } else if (ActivityCompat.checkSelfPermission(context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.CAMERA), MY_PERMISSIONS_REQUESTS_CAMERA)
        } else if (ActivityCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {

            ActivityCompat.requestPermissions(activity, arrayOf(
                    Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), MY_PERMISSIONS_REQUESTS_CAMERA)
        } else {
            captureImage()
        }
    }

    private fun checkPermissionGallery() {
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity, arrayOf(
                    Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), MY_PERMISSIONS_REQUESTS_GALLERY)
        } else {
            getImage()
        }
    }

    fun getImage() {
        val intent = Intent(Intent.ACTION_PICK)
        intent.type = "image/*"
        activity.startActivityForResult(intent, GALLERY)
    }

    private fun captureImage() {
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        val file: File = CameraUtils.getOutputMediaFile(MEDIA_TYPE_IMAGE)
        imageStoragePath = file.getAbsolutePath()
        val fileUri: Uri = CameraUtils.getOutputMediaFileUri(applicationContext, file)
        intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri)

        // start the image capture Intent
        startActivityForResult(intent, CAMERA_CAPTURE_IMAGE_REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if(requestCode == MY_PERMISSIONS_REQUESTS_CAMERA) {
            if (grantResults.size > 1 && grantResults[0] ==
                    PackageManager.PERMISSION_GRANTED && grantResults[1] ==
                    PackageManager.PERMISSION_GRANTED) {
                //permission from popup granted
                captureImage()
            } else if (grantResults.size > 0 && grantResults[0] ==
                    PackageManager.PERMISSION_GRANTED) {
                //permission from popup granted
                if (ActivityCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
                        && ActivityCompat.checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
                        && ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
                    captureImage()
                } else {
                    pendingHintResult?.success("no")
                    Toast.makeText(activity, "Permission denied", Toast.LENGTH_SHORT).show()
                }

            } else {
                //permission from popup denied
                pendingHintResult?.success("no")
                Toast.makeText(activity, "Permission denied", Toast.LENGTH_SHORT).show()
            }
        }else if(requestCode == MY_PERMISSIONS_REQUESTS_GALLERY) {
            if (grantResults.size > 0 && grantResults[0] ==
                    PackageManager.PERMISSION_GRANTED) {
                //permission from popup granted
                getImage()
            } else {
                //permission from popup denied
                Toast.makeText(activity, "Permission denied", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        /* if(resultCode != Activity.RESULT_CANCELED)
         {*/
        try{
             if (requestCode == CAMERA_CAPTURE_IMAGE_REQUEST_CODE) {
                CameraUtils.refreshGallery(getApplicationContext(), imageStoragePath)
                if(check(imageStoragePath)) {
                    pendingHintResult?.success(imageStoragePath)
                } else {
                    pendingHintResult?.success("denied")
                }
                // Refreshing the gallery
                // CameraUtils.refreshGallery(getApplicationContext(), imageStoragePath);
                // Toast.makeText(this, imageStoragePath, Toast.LENGTH_LONG).show()
            } else if (requestCode == GALLERY) {
                // Refreshing the gallery
                // CameraUtils.refreshGallery(getApplicationContext(), imageStoragePath);
                val selectedImageUri = data!!.data
                imageStoragePath = getPath(this, selectedImageUri)!!
                pendingHintResult?.success(imageStoragePath)
            } else {
                //  pendingHintResult?.success(null)
            }
        }catch (e : NullPointerException)
        {
            // pendingHintResult?.success(null)
        }

        /* }else{
             pendingHintResult?.success(null)
         }*/
    }

    fun check(path: String?): Boolean {
        val file = File(path)
        return file.exists()
    }

    fun getPath(context: Context, uri: Uri?): String? {
        var result: String? = null
        val proj = arrayOf(MediaStore.Images.Media.DATA)
        val cursor: Cursor = context.getContentResolver().query(uri!!, proj, null, null, null)!!

        if (cursor.moveToFirst()) {
            val column_index: Int = cursor.getColumnIndexOrThrow(proj[0])
            result = cursor.getString(column_index)
        }
        cursor.close()

        if (result == null) {
            result = "Not found"
        }
        return result
    }
}

