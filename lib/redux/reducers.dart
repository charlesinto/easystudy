import 'package:studyapp/model/app_state.dart';
import 'package:studyapp/model/app_userreport.dart';
import 'package:studyapp/redux/actions.dart';
 

AppState reducer(AppState prevState, dynamic action){
  AppState newState = AppState.fromAppState(prevState);
  if(action is TabIndex){
     newState.selectedTabIndex = action.payload;
  }
  if(action is SelectSubject){
    newState.selectedSubject = action.payload;
  }
  if(action is SelectedMaterial){
    newState.selectedMaterial = action.payload;
  }
  if(action is SelectedRoom){
    newState.selectedRoom = action.payload;
  }
  if(action is EducationLevel){
    newState.educationLevel = action.payload;
  }
  if(action is SchoolLevel){
    newState.schoolLevel = action.payload;
  }
  if(action is MaterialLoaded){
    newState.materials = action.payload;
  }
  if(action is OnTestSelected){
    newState.testSelected = action.payload;
  }
  if(action is UserSelectAssessment){
    newState.loggedUser = action.payload;
  }
  if(action is SelectedExamType){
    newState.examtype = action.payload;
  }
  if(action is PracticeQuestionSelected){
    newState.test = action.payload;
  }
  if(action is StartTest){
    newState.testParams = action.payload;
  }
  if(action is ReportGenerated){
    newState.report = action.payload;
  }
  if(action is SetTestMode){
    newState.testMode = action.payload;
  }
  if(action is SelectedResource){
    newState.selectedResource = action.payload;
  }
  if(action is SelectedContent){
    newState.content = action.payload;
  }
  if(action is ResourceToView){
    newState.resource = action.payload;
  }
  return newState;
}