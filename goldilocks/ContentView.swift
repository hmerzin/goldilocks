//
//  ContentView.swift
//  goldilocks
//
//  Created by Harry Merzin on 2/10/23.
//

import Alamofire
import SwiftUI

let circlepow = 6
let rectSize = pow(2, CGFloat(circlepow))
let rectRadius = pow(2, CGFloat(circlepow - 1))

struct Entry: Identifiable, Hashable {
  let id = UUID()
  let name: String
  let color: Color
  let profilePic: String
}

let entries = [
  Entry(name: "Harry", color: .teal, profilePic: "🍣"),
  Entry(name: "Matt", color: .yellow, profilePic: "🐠"),
  Entry(name: "Max", color: .green, profilePic: "🐡"),
  Entry(name: "V", color: .orange, profilePic: "🎣"),

]

struct ProfileView: View {
  var entry: Entry
  var body: some View {
    NavigationView {
      Text(entry.name).font(.largeTitle)
    }
  }
}

struct TFStyle: TextFieldStyle {
  @Environment(\.colorScheme) var colorScheme
  func _body(configuration: TextField<Self._Label>) -> some View {
    VStack {
      configuration.fontWeight(.heavy).textFieldStyle(.plain)
        .offset(x: 20)
        .overlay(
          RoundedRectangle(cornerRadius: 10).stroke(
            colorScheme == .dark ? .white : .black, lineWidth: 3
          ).frame(height: 40))
      //.border(.gray, width: 2).cornerRadius(4)
      //            Rectangle().frame(height: 3, alignment: .bottom).offset(y: -5).foregroundColor(.orange).cornerRadius(CGFloat(0.0001))
    }
  }
}

struct ButtonStyles: ButtonStyle {
  @Environment(\.colorScheme) var colorScheme

  func makeBody(configuration: Configuration) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(colorScheme == .dark ? .white : .black).frame(height: 40)
      configuration.label.foregroundColor(colorScheme == .dark ? .black : .white).fontWeight(.heavy)
        .font(.system(.body, design: .rounded))
      //                .fontDesign(.rounded)
      //            .stroke(.black, lineWidth: 3).frame(height: 40))
    }.opacity(configuration.isPressed ? 0.8 : 1.0)
      .scaleEffect(configuration.isPressed ? 0.7 : 1.0).animation(
        .spring(dampingFraction: 0.3), value: configuration.isPressed)
    //.interpolatingSpring(mass: 0.8, stiffness: 10, damping: 10, initialVelocity: 3), value: pressed)
  }
}

struct TFModifier: ViewModifier {
  func body(content: Content) -> some View {
    VStack {
      content
      Rectangle().frame(height: 1, alignment: .bottom).offset(y: -5)
    }
  }
}

struct PhoneNumberEntry: View {
  @Binding var phoneNumber: String
  let pnPattern = "(XXX) XXX-XXXX"

  var body: some View {
    TextField(pnPattern, text: $phoneNumber)
      .keyboardType(.numberPad)
      .textFieldStyle(TFStyle()).onChange(
        of: phoneNumber,
        perform: { newValue in
          var newString = ""
          let numbers = phoneNumber.replacingOccurrences(
            of: "[^0-9]", with: "", options: .regularExpression)
          var numIndex = numbers.startIndex
          for ch in pnPattern where numIndex < numbers.endIndex {
            if ch != "X" {
              newString += "\(ch)"
            } else if numIndex < numbers.endIndex {
              newString.append(numbers[numIndex])
              numIndex = numbers.index(after: numIndex)
            }
          }
          phoneNumber = newString
        })
  }
}

struct FormView<ContentA: View, ContentB: View>: View {

  init(
    title: String, subtitle: String, emoji: String, textField: ContentA, button: ContentB,
    error: Binding<String?> = .constant(nil)
  ) {
    self.title = title
    self.subtitle = subtitle
    self.emoji = emoji
    self.textField = textField
    self.button = button
    self._error = error
  }

  var title: String
  var subtitle: String
  var emoji: String
  @ViewBuilder var textField: ContentA
  @ViewBuilder var button: ContentB
  @Binding var error: String?

  var body: some View {
    VStack(alignment: .leading) {
      Text(title).font(.system(.title, design: .rounded)).fontWeight(.heavy)
      Spacer().frame(height: 32)
      Text(subtitle).font(.system(.title2, design: .rounded)).fontWeight(.semibold).foregroundColor(
        .gray)
      Spacer()
      textField
      Group {
        Spacer()
        VStack(alignment: .center) {
          Text(emoji).font(.custom("HUGE", size: 150)).frame(alignment: .center).frame(
            maxWidth: .infinity
          ).ignoresSafeArea(.keyboard, edges: .bottom).frame(minHeight: 10)
        }
        //                Spacer()
        //                Spacer()
        Spacer()
      }
      if error != nil {
        Text(error!).font(.system(.body, design: .rounded)).fontWeight(.heavy).foregroundColor(.red)
      }
      button
    }.padding().padding([.top], 24)
  }
}

struct SubmitButton: View {
  var action: (() -> Void)?
  var loading: Binding<Bool>? = nil

  var body: some View {
    Button {
      if action != nil {
        action!()
      }

    } label: {
      Text("Submit").frame(maxWidth: .infinity)
    }.buttonStyle(ButtonStyles()).disabled(loading != nil && loading!.wrappedValue)
  }
}

struct NumberNavLink: View {
  @Binding var name: String
  var body: some View {
    NavigationLink("Submit") {
      //            NumberView(name: name)
    }.buttonStyle(ButtonStyles())
    //        {
    //            NumberView(name: name)
    //        } label: {
    ////            SubmitButton()
    //            Text("Test")
    //        }.buttonStyle(ButtonStyles())
  }
}

struct UsersView: View {
  @StateObject var users = Users()
  var onLogout: () -> Void
  var body: some View {
    var _ = debugPrint(users.users)
    VStack(alignment: .leading) {
      List($users.users) { $entry in
        Section {
          NavigationLink {
            Text(entry.name)
          } label: {
            HStack {
              ProfilePicture(color: randomColor(), emoji: randomFish())
              Text(entry.name).padding().font(.title2).fontWeight(.bold)
            }
          }
        } header: {
          Text("Users").font(.system(.title2, design: .rounded)).fontWeight(.semibold).foregroundColor(
            .gray)
          
        }.textCase(.none)
      }.refreshable {
        users.getUsers()
      }
      .listStyle(.insetGrouped)
      Button(
        "Logout",
        action: {
          onLogout()
        }
      ).buttonStyle(ButtonStyles()).padding()
    }.onAppear {
      users.getUsers()
    }.padding([.top])
  }
}

struct ProfilePicture: View {
  var color: Color
  var emoji: String
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: rectRadius).foregroundColor(color).frame(
        width: rectSize, height: rectSize)
      Text(emoji).font(.custom("Large", fixedSize: 40))

    }
  }
}

struct ContentView: View {
  @State var done: Bool = UserDefaults.standard.value(forKey: "Token") != nil
  init() {
//    UserDefaults.standard.set("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2NzYzMTcxNzQsImV4cCI6MTcwNzg3NDc3NH0.HjzSPH1u6BvDo1y5HfwHFoTWIYDUZBGnTpXc7vb-KGU", forKey: "Token")
    print("DONE:", done)
  }
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  var body: some View {
    NavigationView {
      let _ = print("DONE: ", done)
      if !done {
        SignupFlow(done: $done)
      } else {
        UsersView(onLogout: {
          UserDefaults.standard.removeObject(forKey: "Token")
          done = false
        }).navigationTitle("Welcome 34 Cal")
          .background(colorScheme == .dark ? .black : Color(.systemGroupedBackground))
      }
    }.font(.system(.body, design: .rounded))
  }
}

struct NameView: View {
  @State private var name: String = ""
  @State private var transition: Bool? = false
  @Environment(\.colorScheme) var colorScheme
  var login: () -> Void
  var onSubmit: (_: String) -> Void
  var body: some View {
    FormView(
      title: "Let's get introduced", subtitle: "What's your name?", emoji: randomFish(),
      textField: Group {
        TextField("Name", text: $name).textFieldStyle(TFStyle())
        Spacer().frame(height: 24)
        Button(
          "Already Have an account?",
          action: {
            login()
          }
        ).padding([.leading], 6).foregroundColor(colorScheme == .dark ? .white: .black).fontWeight(.heavy)
      },
      button: SubmitButton(action: {
        onSubmit(name)
      })  //                        NumberNavLink(name: $name)
    )
  }
}

struct NumberView: View {
  @Binding var name: String
  @Binding var phoneNumber: String
  @Binding var loading: Bool
  //    @State private var phoneNumber: String = ""
  var onSubmit: () -> Void

  var body: some View {
    FormView(
      title: "Hello \(name), Let's get you verified", subtitle: "What's your phone number?",
      emoji: randomFish(),

      textField: PhoneNumberEntry(phoneNumber: $phoneNumber),
      button: SubmitButton(
        action: {
          onSubmit()
        }, loading: $loading))
    // Button {} label: {Text("Submit").frame(maxWidth: .infinity)}.buttonStyle(ButtonStyles()))
  }
}

struct VerifyView: View {
  @State var code: String = ""
  var onSubmit: (_: String) -> Void
  @Binding var error: String?
  @Binding var loading: Bool

  var body: some View {
    FormView(
      title: "Almost There", subtitle: "Now what was that code again?", emoji: "🐡",

      textField: TextField("Code", text: $code).textFieldStyle(TFStyle()),
      button: SubmitButton(
        action: {
          onSubmit(code)
        }, loading: $loading), error: $error)
    // Button {} label: {Text("Submit").frame(maxWidth: .infinity)}.buttonStyle(ButtonStyles()))
  }

}

struct VerifyResponse: Decodable {
  var token: String
}

struct SignupFlow: View {
  @State private var navStack = [Int]()
  @State private var name = ""
  @State private var numbers = ""
  @State private var phoneNumber = ""
  @State var error: String?
  @State var loading: Bool = false
  @State var login: Bool = false
  @Binding var done: Bool


  func onSubmitNumber() {
    loading = true
    AF.request(
      "\(BASE_URL)/signup", method: .post,
      parameters: ["name": name, "phoneNumber": numbers], encoder: JSONParameterEncoder.default
    ).response { response in
      loading = false
      debugPrint(response)
      if response.response?.statusCode == 200 {
        navStack.append(1)
      }
    }
  }

  func onSubmitCode(code: String) {
    loading = true
    AF.request(
      "\(BASE_URL)/verify", method: .post,
      parameters: ["code": code, "phoneNumber": numbers, "name": name], encoder: JSONParameterEncoder.default
    ).responseDecodable(of: VerifyResponse.self) { response in
      loading = false
      debugPrint(response)
      if response.response?.statusCode != 200 {
        error = "Failed to verify, please try again!"
        return
      }
      if response.value?.token == nil {
        error = "Failed to obtain token, please try again"
      }
      UserDefaults.standard.setValue(response.value?.token, forKey: "Token")
      done = true
    }
  }

  var body: some View {
    NavigationStack(path: $navStack) {
      NameView(
        login: {
            navStack.append(0)
        },
        onSubmit: { n in
          name = n
          navStack.append(0)
        }
      ).navigationDestination(for: Int.self) { i in
        if i == 0 {
          NumberView(
            name: $name, phoneNumber: $phoneNumber, loading: $loading, onSubmit: onSubmitNumber)  //.navigationBarBackButtonHidden(true)
        } else if i == 1 {
          VerifyView(onSubmit: onSubmitCode, error: $error, loading: $loading)
        }
      }

    }.onChange(
      of: phoneNumber,
      perform: { newNumber in
        numbers =
          "+1\(phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))"
      })
  }
}

struct ContentView_Previews: PreviewProvider {
  @State var done: Bool = false
  static var previews: some View {
    ContentView()
    //        ProfilePicture(color:.green, emoji: "🍣")
    //        NumberView(name: "Harry" )
    SignupFlow(done: .constant(false))
    UsersView(onLogout: {
      print("log out")

    })
  }
}
