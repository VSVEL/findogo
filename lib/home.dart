import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isWorking = false;
  String result = '';
  CameraController cameraController;
  CameraImage imgCamera;

  initCamera(){
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value){
      if(!mounted){
        return;
      }

      setState(() {
        cameraController.startImageStream((imageFromStream) =>
        {
          if(!isWorking){
            isWorking = true,
            imgCamera = imageFromStream,
            runModelOnStreamFrames(),
          }
        });
      });

    });
  }


  loadModel() async{
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt"
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }


  runModelOnStreamFrames() async{
    if(imgCamera!= null){
      var recognition = await Tflite.runModelOnFrame(
          bytesList: imgCamera.planes.map((plane)
          {
            return plane.bytes;
          }).toList(),
        
        imageHeight: imgCamera.height,
        imageWidth: imgCamera.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      result = '';
      
      recognition.forEach((response)
      {
        result += response["label"] + "   " +
            (response['confidence'] as double).toStringAsFixed(2)+ "\n\n";
      });
      setState(() {
        result;
      });
      isWorking = false;
    }
  }

  @override
  void dispose() async{
    // TODO: implement dispose
    super.dispose();

    await Tflite.close();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("FINDOGO",),centerTitle: true,),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/back.jpg"),
                fit: BoxFit.fill,
              )
            ),
            child: Column(
              children: [
                Stack(

                  children: [

                    Center(
                      child: TextButton(
                        onPressed: (){

                          initCamera();
                        },
                        child: Container(
                          height: 400.0,
                          width: 400.0,
                          child: imgCamera == null
                          ?
                              Container(
                                height: 400.0,
                                width: 400.0,
                                  child: Icon(Icons.photo_camera_back,color: Colors.deepPurpleAccent,)
                              )
                              :
                              AspectRatio(aspectRatio: cameraController.value.aspectRatio,
                              child : CameraPreview(cameraController)),
                        ),
                      ),
                    )
                  ],
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        style: TextStyle(
                          backgroundColor: Colors.white54,
                          fontSize: 25.0,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
