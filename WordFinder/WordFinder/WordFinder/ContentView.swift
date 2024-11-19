//
//  ContentView.swift
//  WordScramble
//
//  Created by Abir Rahman on 18/11/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    @State private var score = 0

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Text("Word Finder")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .shadow(radius: 10)

                    Text(rootWord)
                        .font(.title)
                        .fontWeight(.black)
                        .padding()
                        .background(Capsule().fill(Color.white.opacity(0.8)))
                        .shadow(radius: 5)

                    TextField("Enter your word", text: $newWord)
                        .padding()
                        .background(Capsule().fill(Color.white))
                        .shadow(radius: 5)
                        .textInputAutocapitalization(.never)
                        .padding()

                    List {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle.fill")
                                    .foregroundColor(.blue)
                                Text(word)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding(5)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)

                    Text("Score: \(score)")
                        .font(.title2.bold())
                        .padding()
                        .background(Capsule().fill(Color.white.opacity(0.8)))
                        .shadow(radius: 5)
                        .foregroundColor(.green)
                }
                .padding()
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
        }
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else { return }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }

        score += answer.count
        newWord = ""
    }

    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }

        fatalError("Could not load start.txt from bundle.")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
