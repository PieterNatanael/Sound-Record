//
//  ContentView.swift
//  Sound Record
//
//  Created by Pieter Yoshua Natanael on 30/08/24.
//


import SwiftUI
import AVFoundation

// Delegate for handling audio capture events
class AudioCaptureDelegate: NSObject, AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Audio recording error.")
        } else {
            print("Audio recorded successfully: \(recorder.url.absoluteString)")
        }
    }
}

struct ContentView: View {
    // State variables
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioURL: URL?
    @State private var audioQuality: AVAudioQuality = .high // Default to High quality
    private let audioCaptureDelegate = AudioCaptureDelegate()
    
    @State private var showExplain: Bool = false
    
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                HStack{
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
                
                // Start/Stop Recording Button
                Button(action: {
                    if self.isRecording {
                        self.stopRecording()
                    } else {
                        self.startRecording()
                    }
                }) {
                    Text(self.isRecording ? "Stop" : "Start")
                }
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(isRecording ? Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)) : Color.white)
                .cornerRadius(25)
                .foregroundColor(Color.black)
                .padding(.bottom, 18)
                
                // Export Button
                Button(action: {
                    self.exportAudio()
                }) {
                    Text("Export")
                }
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(Color(#colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)))
                .cornerRadius(25)
                .foregroundColor(.white)
                Spacer()
            }
            .onAppear {
                self.setupAudioSession()
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(isPresented: $showExplain, audioQuality: $audioQuality)
            }
        }
    }
    
    // Setup the audio session
    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
            print("Audio session set up successfully.")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // Start audio recording
    func startRecording() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let fileURL = paths.first?.appendingPathComponent("audio\(Date().timeIntervalSince1970).m4a") else {
            print("Failed to create file URL.")
            return
        }
        self.audioURL = fileURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: audioQuality.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = audioCaptureDelegate
            audioRecorder?.record()
            self.isRecording = true
            print("Recording started.")
        } catch {
            print("Failed to start audio recording: \(error.localizedDescription)")
        }
    }
    
    
    // Stop audio recording
    func stopRecording() {
        audioRecorder?.stop()
        self.isRecording = false
        print("Recording stopped.")
    }
    
    // Export audio
    func exportAudio() {
        guard let audioURL = self.audioURL else {
            print("Audio URL is nil.")
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [audioURL], applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = window.rootViewController?.view
                popoverController.sourceRect = CGRect(x: window.frame.midX, y: window.frame.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            window.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }

    
//    // Export audio
//    func exportAudio() {
//        guard let audioURL = self.audioURL else {
//            print("Audio URL is nil.")
//            return
//        }
//        
//        let activityViewController = UIActivityViewController(activityItems: [audioURL], applicationActivities: nil)
//        
//        if let popoverController = activityViewController.popoverPresentationController {
//            popoverController.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
//            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
//            popoverController.permittedArrowDirections = []
//        }
//        
//        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
//    }
//    
    
    // MARK: - Ads App Card View
    
    /// A view to display an individual ads app card.
    struct AppCardView: View {
        var imageName: String
        var appName: String
        var appDescription: String
        var appURL: String
        
        var body: some View {
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(7)
                
                VStack(alignment: .leading) {
                    Text(appName)
                        .font(.title.bold())
                    Text(appDescription)
                        .font(.title)
                }
                .frame(alignment: .leading)
                
                Spacer()
                //            Button(action: {
                //                if let url = URL(string: appURL) {
                //                    UIApplication.shared.open(url)
                //                }
                //            }) {
                //                Text("Try")
                //                    .font(.headline)
                //                    .padding()
                //                    .foregroundColor(.white)
                //                    .background(Color.blue)
                //                    .cornerRadius(10)
                //            }
            }
            .onTapGesture {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    
    // MARK: - Explanation and Audio Quality Selection View
    struct ShowExplainView: View {
        @Binding var isPresented: Bool
        @Binding var audioQuality: AVAudioQuality
        
        var body: some View {
            ScrollView {
                VStack {
                    Text("Audio Quality")
                        .font(.title.bold())
                    Picker("Select Audio Quality", selection: $audioQuality) {
                        Text("Normal").tag(AVAudioQuality.medium)
                        Text("High").tag(AVAudioQuality.high)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Text("App Functionality")
                        .font(.title.bold())
                    Text("""
                • Press start to begin recording audio.
                • Press stop to stop recording.
                • Press export to export the file.
                • The app overwrites previous data when the start button is pressed again.
                • The app cannot run in the background; auto-lock should be set to 'Never' to avoid turning off due to inactivity.
                """)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .padding()
                    
                    
                    // Ads App Cards
                    
                    Text("App for you")
                        .font(.title.bold())
                    
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Why read when you can listen on a loop? Easily adjust the reading speed to suit your needs.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    
                    
                    
                    Divider().background(Color.gray)
                    AppCardView(imageName: "sos", appName: "SOS light", appDescription: "SOS Light is designed to maximize the chances of getting help in emergency situations.", appURL: "https://apps.apple.com/app/s0s-light/id6504213303")
                    
                    Divider().background(Color.gray)
                    AppCardView(imageName: "worry", appName: "Worry Bin", appDescription: " Helps you track, manage, and conquer your worries like never before.", appURL: "https://apps.apple.com/id/app/worry-bin/id6498626727")
                    
                    
                    Divider().background(Color.gray)
                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record long videos easily, adjust video quality easily, and reduce file size.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                    Divider().background(Color.gray)
                    AppCardView(imageName: "angry", appName: "AngryKid", appDescription: "Guide for parents. Empower your child's emotions. Journal anger, export for parent understanding.", appURL: "https://apps.apple.com/id/app/angry-kid/id6499461061")
                    Divider().background(Color.gray)
                    AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                    Divider().background(Color.gray)
                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                    Divider().background(Color.gray)
                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    Divider().background(Color.gray)
                    //                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, and set goals.", appURL: "https://apps.apple.com/id/app/temptation-track/id6449725104")
                    //                    Divider().background(Color.gray)
                    
                    
                    
                    // Audio Quality Selection
                    
                    Button("Close") {
                        isPresented = false
                    }
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.vertical, 10)
                }
                .padding()
            }
        }
    }}

#Preview {
    ContentView()
}

/*
import SwiftUI
import AVFoundation

// Delegate for handling audio capture events
class AudioCaptureDelegate: NSObject, AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Audio recording error.")
        } else {
            print("Audio recorded successfully: \(recorder.url.absoluteString)")
        }
    }
}

struct ContentView: View {
    // State variables
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioURL: URL?
    @State private var audioQuality: AVAudioQuality = .high // Default to High quality
    private let audioCaptureDelegate = AudioCaptureDelegate()
  
    @State private var showExplain: Bool = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                HStack{
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
                
                // Start/Stop Recording Button
                Button(action: {
                    if self.isRecording {
                        self.stopRecording()
                    } else {
                        self.startRecording()
                    }
                }) {
                    Text(self.isRecording ? "Stop" : "Start")
                }
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(isRecording ? Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)) : Color.white)
                .cornerRadius(25)
                .foregroundColor(Color.black)
                .padding(.bottom, 18)
                
                // Export Button
                Button(action: {
                    self.exportAudio()
                }) {
                    Text("Export")
                }
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(Color(#colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)))
                .cornerRadius(25)
                .foregroundColor(.white)
                Spacer()
            }
            .onAppear {
                self.setupAudioSession()
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(isPresented: $showExplain, audioQuality: $audioQuality)
            }
        }
    }
    
    // Setup the audio session
    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
            print("Audio session set up successfully.")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // Start audio recording
    func startRecording() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let fileURL = paths.first?.appendingPathComponent("audio\(Date().timeIntervalSince1970).m4a") else {
            print("Failed to create file URL.")
            return
        }
        self.audioURL = fileURL

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: audioQuality.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = audioCaptureDelegate
            audioRecorder?.record()
            self.isRecording = true
            print("Recording started.")
        } catch {
            print("Failed to start audio recording: \(error.localizedDescription)")
        }
    }

    // Stop audio recording
    func stopRecording() {
        audioRecorder?.stop()
        self.isRecording = false
        print("Recording stopped.")
    }

    // Export audio
    func exportAudio() {
        guard let audioURL = self.audioURL else {
            print("Audio URL is nil.")
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [audioURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Ads App Card View

/// A view to display an individual ads app card.
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)

            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title.bold())
                Text(appDescription)
                    .font(.title)
            }
            .frame(alignment: .leading)

            Spacer()
//            Button(action: {
//                if let url = URL(string: appURL) {
//                    UIApplication.shared.open(url)
//                }
//            }) {
//                Text("Try")
//                    .font(.headline)
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
        }
        .onTapGesture {
            if let url = URL(string: appURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}


// MARK: - Explanation and Audio Quality Selection View
struct ShowExplainView: View {
    @Binding var isPresented: Bool
    @Binding var audioQuality: AVAudioQuality

    var body: some View {
        ScrollView {
            VStack {
                Text("Audio Quality")
                    .font(.title.bold())
                Picker("Select Audio Quality", selection: $audioQuality) {
                    Text("Normal").tag(AVAudioQuality.medium)
                    Text("High").tag(AVAudioQuality.high)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Text("App Functionality")
                    .font(.title.bold())
                Text("""
                • Press start to begin recording audio.
                • Press stop to stop recording.
                • Press export to export the file.
                • The app overwrites previous data when the start button is pressed again.
                • The app cannot run in the background; auto-lock should be set to 'Never' to avoid turning off due to inactivity.
                """)
                .font(.title3)
                .multilineTextAlignment(.leading)
                .padding()
                
                
                // Ads App Cards
                
                Text("App for you")
                    .font(.title.bold())
                    
                    Divider().background(Color.gray)
                    
                                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Why read when you can listen on a loop? Easily adjust the reading speed to suit your needs.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                                      
                 
                    
                    Divider().background(Color.gray)
                    AppCardView(imageName: "sos", appName: "SOS light", appDescription: "SOS Light is designed to maximize the chances of getting help in emergency situations.", appURL: "https://apps.apple.com/app/s0s-light/id6504213303")
                    
                    Divider().background(Color.gray)
                    AppCardView(imageName: "worry", appName: "Worry Bin", appDescription: " Helps you track, manage, and conquer your worries like never before.", appURL: "https://apps.apple.com/id/app/worry-bin/id6498626727")
                   
                    
                    Divider().background(Color.gray)
                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record long videos easily, adjust video quality easily, and reduce file size.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                    Divider().background(Color.gray)
                    AppCardView(imageName: "angry", appName: "AngryKid", appDescription: "Guide for parents. Empower your child's emotions. Journal anger, export for parent understanding.", appURL: "https://apps.apple.com/id/app/angry-kid/id6499461061")
                    Divider().background(Color.gray)
                    AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                    Divider().background(Color.gray)
             
                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                    Divider().background(Color.gray)
                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                    Divider().background(Color.gray)
                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    Divider().background(Color.gray)
//                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, and set goals.", appURL: "https://apps.apple.com/id/app/temptation-track/id6449725104")
//                    Divider().background(Color.gray)
                
            

                // Audio Quality Selection
         
                Button("Close") {
                    isPresented = false
                }
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.vertical, 10)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

*/

/*
import SwiftUI
import AVFoundation

// Delegate for handling audio capture events
class AudioCaptureDelegate: NSObject, AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Audio recording error.")
        } else {
            print("Audio recorded successfully: \(recorder.url.absoluteString)")
        }
    }
}

struct ContentView: View {
    // State variables
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioURL: URL?
    @State private var audioQuality: AVAudioQuality = .high // Default to High quality
    private let audioCaptureDelegate = AudioCaptureDelegate()
  
    @State private var showExplain: Bool = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                HStack{
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
                
                // Start/Stop Recording Button
                Button(action: {
                    if self.isRecording {
                        self.stopRecording()
                    } else {
                        self.startRecording()
                    }
                }) {
                    Text(self.isRecording ? "Stop" : "Start")
                }
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(isRecording ? Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)) : Color.white)
                .cornerRadius(25)
                .foregroundColor(isRecording ? Color.black : Color.black)
                .padding(.bottom, 18)
                
                // Export Button
                Button(action: {
                    self.exportAudio()
                }) {
                    Text("Export")
                }
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(Color(#colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1)))
                .cornerRadius(25)
                .foregroundColor(.white)
                Spacer()
            }
            .onAppear {
                self.setupAudioSession()
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(isPresented: $showExplain, audioQuality: $audioQuality)
            }
        }
    }
    
    // Setup the audio session
    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // Start audio recording
    func startRecording() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent("audio\(Date().timeIntervalSince1970).mp3")
        self.audioURL = fileURL

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: audioQuality.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = audioCaptureDelegate
            audioRecorder?.record()
            self.isRecording = true
        } catch {
            print("Failed to start audio recording: \(error.localizedDescription)")
        }
    }

    // Stop audio recording
    func stopRecording() {
        audioRecorder?.stop()
        self.isRecording = false
    }

    // Export audio
    func exportAudio() {
        guard let audioURL = self.audioURL else {
            print("Audio URL is nil.")
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [audioURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Explanation and Audio Quality Selection View
struct ShowExplainView: View {
    @Binding var isPresented: Bool
    @Binding var audioQuality: AVAudioQuality

    var body: some View {
        VStack {
            Text("Audio Quality")
                .font(.title.bold())
            Picker("Select Audio Quality", selection: $audioQuality) {
                Text("Normal").tag(AVAudioQuality.medium)
                Text("High").tag(AVAudioQuality.high)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Text("App Functionality")
                .font(.title.bold())
            Text("""
            • Press start to begin recording audio.
            • Press stop to stop recording.
            • Press export to export the file.
            • The app overwrites previous data when the start button is pressed again.
            • The app cannot run in the background; auto-lock should be set to 'Never' to avoid turning off due to inactivity.
            """)
            .font(.title3)
            .multilineTextAlignment(.leading)
            .padding()
            
            // Audio Quality Selection
     
            Button("Close") {
                isPresented = false
            }
            .font(.title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.vertical, 10)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

*/
/*
import SwiftUI
import AVFoundation

// Delegate for handling audio capture events
class AudioCaptureDelegate: NSObject, AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Audio recording error.")
        } else {
            print("Audio recorded successfully: \(recorder.url.absoluteString)")
        }
    }
}

struct ContentView: View {
    // State variables
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioURL: URL?
    private let audioCaptureDelegate = AudioCaptureDelegate()
  
    @State private var showExplain: Bool = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                HStack{
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
                
                // Start/Stop Recording Button
                Button(action: {
                    if self.isRecording {
                        self.stopRecording()
                    } else {
                        self.startRecording()
                    }
                }) {
                    Text(self.isRecording ? "Stop" : "Start")
                }
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(isRecording ? Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)) : Color.white)
                .cornerRadius(25)
                .foregroundColor(isRecording ? Color.black : Color.black)
                .padding(.bottom, 18)
                
                // Export Button
                Button(action: {
                    self.exportAudio()
                }) {
                    Text("Export")
                }
                .font(.title2)
                .padding()
                .frame(width: 233)
                .background(Color(#colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)))
                .cornerRadius(25)
                .foregroundColor(.white)
                Spacer()
            }
            .onAppear {
                self.setupAudioSession()
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(isPresented: $showExplain)
            }
        }
    }
    
    // Setup the audio session
    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // Start audio recording
    func startRecording() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent("audio\(Date().timeIntervalSince1970).mp3")
        self.audioURL = fileURL

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = audioCaptureDelegate
            audioRecorder?.record()
            self.isRecording = true
        } catch {
            print("Failed to start audio recording: \(error.localizedDescription)")
        }
    }

    // Stop audio recording
    func stopRecording() {
        audioRecorder?.stop()
        self.isRecording = false
    }

    // Export audio
    func exportAudio() {
        guard let audioURL = self.audioURL else {
            print("Audio URL is nil.")
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [audioURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Explanation View
struct ShowExplainView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("App Functionality")
                .font(.title.bold())
            Text("""
            • Press start to begin recording audio.
            • Press stop to stop recording.
            • Press export to export the file.
            • The app overwrites previous data when the start button is pressed again.
            • The app cannot run in the background; auto-lock should be set to 'Never' to avoid turning off due to inactivity.
            """)
            .font(.title3)
            .multilineTextAlignment(.leading)
            .padding()
            
            Button("Close") {
                isPresented = false
            }
            .font(.title)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
#Preview {
    ContentView()
}
*/

/*
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
*/
