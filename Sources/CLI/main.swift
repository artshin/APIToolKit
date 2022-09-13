import APIToolKit
import CommandLineKit

enum IpifyRestEndpoint: RestEndpoint {
  case getIP

  var path: String {
    switch self {
    case .getIP:
      return "/"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .getIP:
      return .get
    }
  }

  var parameters: Parameters {
    switch self {
    case .getIP:
      return .query(params: .init(params: ["format": "json"]))
    }
  }

  var headers: [String : String]? {
    nil
  }
}

struct IpifyResponse: Decodable {
  let ip: String
}

struct Repl {
  private let lineReader = LineReader()

  init() {
    lineReader?.setCompletionCallback { currentBuffer in
      let completions = [
        "Hello, world!",
        "Hello, Linenoise!",
        "Swift is Awesome!"
      ]
      return completions.filter { $0.hasPrefix(currentBuffer) }
    }

    lineReader?.setHintsCallback { currentBuffer in
      let hints = [
        "Carpe Diem",
        "Lorem Ipsum",
        "Swift is Awesome!"
      ]
      let filtered = hints.filter { $0.hasPrefix(currentBuffer) }
      if let hint = filtered.first {
        let hintText = String(hint.dropFirst(currentBuffer.count))
        return (hintText, TextColor.grey.properties)
      } else {
        return nil
      }
    }
  }

  func getUserInput() -> String {
    var input = "exit"
    guard let lineReader = lineReader else {
      return input
    }

    do {
      input = try lineReader.readLine(
        prompt: "> ",
        maxCount: 200,
        strippingNewline: true,
        promptProperties: TextProperties(.green, nil, .bold),
        readProperties: TextProperties(.blue, nil),
        parenProperties: TextProperties(.red, nil, .bold)
      )

      print("Entered: \(input)")
    } catch LineReaderError.CTRLC {
      print("\nCaptured CTRL+C. Quitting.")
    } catch {
      print(error)
    }

    return input
  }
}

class Main {
  var running = true
  var isPerformingOperation = false
  let repl = Repl()
  let client = Rest.Client(baseUrl: "https://api.ipify.org")

  func run() {
    print("Detected terminal: \(Terminal.current)")
    print(Terminal.fullColorSupport ? "Full color support" : "No color support")
    print(LineReader.supportedByTerminal ? "LineReader support" : "No LineReader support")
    print("Type 'exit' to quit")

    while running {
      if isPerformingOperation {
        continue
      }

      let input = repl.getUserInput()

      if input == "exit" {
        running = false
      }

      if input == "ip" {
        getIp()
      }
    }
  }

  private func getIp() {
    isPerformingOperation = true

    Task {
      do {
        if let response: IpifyResponse = try await client.request(endpoint: IpifyRestEndpoint.getIP) {
          print(response)
        }
      } catch let error {
        print(error)
      }

      isPerformingOperation = false
    }
  }
}

Main().run()
