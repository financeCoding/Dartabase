import "dart:io";
import "dart:convert";
import "dart:async";

import 'package:dartabase_core/dartabase_core.dart';

import "dartabaseMigration.dart";

/**
 * 
 * reverts all migration files inside 
 * ##/db/migrations 
 * in the "DOWN" key with execution order
 *   -createTable
 *   -createColumn
 *   -removeColumn
 *   -createRelation
 *   -removeRelation
 *   -removeTable    
 *  
 * starting with the last migrated version saved in
 * ##/db/schemaVersion.json (if not the first time)
 *   
 * 
 */
void main() {
  print("|--------------------------|");
  print("|Dartabase revert migration|");
  print("|--------------------------|");
  print("");
  print("Here a List of all Pojects that can be reverted");
  print("Enter the project name and press the ENTER key to proceed");

  projectMapping = DBCore.jsonFilePathToMap("projectsMapping.json");
  
  print("\nProject name *:* Path *:* Current schema version");
  print("-----------------------------");
  
  for(var name in projectMapping.keys){
    Map schemaV = DBCore.jsonFilePathToMap("${projectMapping[name]}/db/schemaVersion.json");
    if(schemaV['schemaVersion'] == "" || schemaV['schemaVersion'] == null){
      //print("$name *:* ${projectMapping[name]} *:* ${schemaV['schemaVersion']}");
    }else{
      print("$name *:* ${projectMapping[name]} *:* ${schemaV['schemaVersion']}");
    }
  }
  Stream<List<int>> stream = stdin;
  
  
  stream
     .transform(UTF8.decoder)
        .transform(new LineSplitter())
          .listen((String line) { /* Do something with line. */
        if(projectMapping[line]!=null){
          String rootPath= projectMapping[line];
          Map rootSchema = DBCore.jsonFilePathToMap("${rootPath}/db/schemaVersion.json");
          Directory directory = new Directory("${rootPath}/db/migrations");
          List files = directory.listSync();
          
          if (files.length > 0) {
            print("\nMigration number : Name");
            print("0 : revert all");
            for(int i=0;i<files.length;i++){ 
              String version = files[i].path.split("migrations")[1].replaceAll("\\","") ;
              if(rootSchema['schemaVersion'] == version ){
                print("${i+1} : $version <--- current version");
              }else{
                print("${i+1} : $version");
              }
            }
          }
          print("please enter goal migration number");
          
         DBCore.rootPath = rootPath;   
          
        }else if(DBCore.rootPath != null){
          lastMigrationNumber = int.parse(line);
          run("DOWN");  
        }else{
          DBCore.rootPath = line;
          run("DOWN");
        }
      },
      onDone: () { /* No more lines */ 
        print("Dartabase migration done!");
      },
     onError: (e) { /* Error on input. */ 
       print("Dartabase migration error! $e");
     });
}