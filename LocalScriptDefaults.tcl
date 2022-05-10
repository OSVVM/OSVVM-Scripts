
  proc AfterLibraryEvent {simulator name path} {
    puts "MFE AfterLibraryEvent $simulator $name $path"
  }

  proc LibraryErrorEvent {errmsg simulator name path} {
    puts "MFE LibraryErrorEvent $errmsg $simulator $name $path"
  }

  proc BeforeLibraryEvent {simulator name path} {
    puts "MFE BeforeLibraryEvent $simulator $name $path"
  }

  proc AfterBuildEvent {simulator path} {
    puts "MFE AfterBuildEvent $simulator $path"
  }

  proc BuildErrorEvent {errmsg simulator path} {
    puts "MFE BuildErrorEvent $errmsg $simulator $path"
  }

  proc BeforeBuildEvent {simulator path} {
    puts "MFE BeforeBuildEvent $simulator $path"
  }

  proc BeforeSimulateEvent {simulator libraryUnit args} {
    puts "MFE BeforeSimulateEvent $simulator $libraryUnit $args"
  }

  proc SimulateErrorEvent {errmsg simulator libraryUnit args} {
    puts "MFE SimulateErrorEvent $errmsg $simulator $libraryUnit $args"
  }

  proc AfterSimulateEvent {simulator libraryUnit args} {
    puts "MFE AfterSimulateEvent $simulator $libraryUnit $args"
  }

  proc BeforeIncludeEvent {simulator path} {
    puts "MFE BeforeIncludeEvent $simulator $path"
  }

  proc IncludeErrorEvent {errmsg simulator path} {
    puts "MFE IncludeErrorEvent $errmsg $simulator $path"
  }

  proc AfterIncludeEvent {simulator path} {
    puts "MFE AfterIncludeEvent $simulator $path"
  }

  proc BeforeAnalyzeEvent {simulator file args} {
    puts "MFE BeforeAnalyzeEvent $simulator $file $args"
  }

  proc AnalyzeErrorEvent {errmsg simulator file args} {
    puts "MFE AnalyzeErrorEvent $errmsg $simulator $file $args"
  }

  proc AfterAnalyzeEvent {simulator file args} {
    puts "MFE AfterAnalyzeEvent $simulator $file $args"
  }

  proc AfterSimulationStartedEvent {simulator libraryName libraryUnit args} {
    puts "MFE AfterSimulationStartedEvent $simulator $libraryName $libraryUnit $args"
  }

  proc GetAdditionalSimulationArguments {simulator libraryUnit args} {
    puts "MFE GetAdditionalSimulationArguments $simulator $libraryUnit $args"
  }
