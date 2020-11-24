//
//  ContentView.swift
//  c60603crud
//
//  Created by User04 on 2020/11/24.
//
import Foundation
import SwiftUI
import Combine

struct BarChart: View{
    @State private var width: CGFloat = 0
    var Width: Double

    var body: some View{
        ZStack(alignment: .bottom) {
            
            Capsule()
            .frame(width: 30, height: 220)
                .foregroundColor(Color(white: 0.805))
            VStack(spacing: 3) {
                Text("\(Int(self.Width))")
                    .foregroundColor(.black)
                Capsule()
                    .frame(width: 30, height: width*20)
                    .animation(.linear(duration: 1))
                    .onAppear{
                        self.width = CGFloat(self.Width)
                }
            }
        }
    }
}

struct BarChartView: View {
    var typeWidths: [Double]

    var body: some View {
        HStack {
            BarChart(Width: typeWidths[0])
                .foregroundColor(.red)
            BarChart(Width: typeWidths[1])
                .foregroundColor(.orange)
            BarChart(Width: typeWidths[2])
                .foregroundColor(.yellow)
            BarChart(Width: typeWidths[3])
                .foregroundColor(.green)
            BarChart(Width: typeWidths[4])
                .foregroundColor(.blue)
        }//.frame(width: 400, height: 500)
    }
}

struct ChartView: View {
    @ObservedObject var championData = ChampionData()
    @State private var selectedChart = "圓餅圖"
    var chart = ["圓餅圖", "柱狀圖"] // donut chart
    var region = ["Top", "Jungle", "Mid", "ADC", "Support"]
    var countryCount: [Double] = [0,0,0,0,0,0,0]
    
    init (championData: ChampionData){
        for champion in championData.countries{
            for i in 0..<5{
                if champion.selectedPosition == region[i]{
                    countryCount[i] += 1
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.init(hue: 0.523, saturation: 0.46, brightness: 1)
                .edgesIgnoringSafeArea(.all)
            //Color.purple.edgesIgnoringSafeArea(.all)
            VStack {
                Text("常玩的位置次數")
                    .font(.system(size: 34))
                    .fontWeight(.heavy)
                Picker(selection: $selectedChart, label: Text("分析圖表")) {
                    ForEach(self.chart, id: \.self) { (Chart) in
                        Text(Chart)
                    }
                }
                    .pickerStyle(SegmentedPickerStyle())
                
                legend() // 圖例
                
                if self.selectedChart == "圓餅圖" {
                    PieChartView(percentages: countryCount)
                    .frame(width: 400, height: 300)
                }
                else if self.selectedChart == "柱狀圖" {
                    BarChartView(typeWidths: countryCount)
                    .frame(width: 400, height: 300)
                }
            }.foregroundColor(Color.black)
        }
    }
}



struct legend: View {
    var body: some View {
        VStack{
            HStack{
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                Text("Top")
                Circle()
                    .fill(Color.orange)
                    .frame(width: 20, height: 20)
                Text("Jungle")
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 20, height: 20)
                Text("Mid")
            }
            HStack{
                Circle()
                    .fill(Color.green)
                    .frame(width: 20, height: 20)
                Text("ADC")
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                Text("Support")
            }
            
        }
    }
}


class ChampionData: ObservableObject{
    var cancellable: AnyCancellable?
    @Published var countries = [Country]()
    
    init(){
        // 解碼，讀檔
        if let data = UserDefaults.standard.data(forKey: "countries"){
          let decoder = JSONDecoder()
          if let decodedData = try? decoder.decode([Country].self, from: data){
            countries = decodedData
          }
        }
        // 編碼，存檔
        cancellable = $countries
            .sink(receiveValue: { (value) in
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(value) {
              UserDefaults.standard.set(data, forKey: "countries")
             }
            })
    }
}

struct Country: Identifiable, Codable {
    var id = UUID()
    var champion: String
    var champion2:String
    var selectedPosition: String
    var finisedtime: Int
    var times: Int
    var favorite: Bool
}

struct ContentView: View {
    @ObservedObject var championData = ChampionData()
       var body: some View {
           VStack{
               TabView {
                   ChampionList(champsData: self.championData)
                       .tabItem {
                           Text("List")
                           Image(systemName: "star.circle.fill")
                   }
                   ChartView(championData: self.championData)
                       .tabItem{
                       Image(systemName: "chart.pie")
                       Text("Chart")
                   }
               }
               .accentColor(.yellow)
           }
       }
}

struct CountryEditor: View {
    @Environment(\.presentationMode) var presentationMode
    var champsData: ChampionData
    @State private var champion = ""
    @State private var champion2 = ""
    @State private var selectedPosition = ""
    @State private var finisedtime : CGFloat = 50
    @State private var times = 1
    @State private var favorite = true
    var disableForm: Bool {
        champion.isEmpty || selectedPosition.isEmpty || champion2.isEmpty
    }
    
    var editCountry: Country?
    var region = ["Top", "Jungle", "Mid", "ADC", "Support"]
    
    var body: some View {
            Form {
                TextField("Champion", text: $champion)
                VStack{
                    Picker(selection: $selectedPosition, label: Text("Position")) {
                        ForEach(self.region, id:\.self) { (city) in
                            Text(city)
                        }
                    }
                }
                TextField("Against", text: $champion2)
                Stepper("遊玩場次: \(times)", value: $times, in: 1...1000)
                HStack {
                    Text("遊戲結束時間: \(Int(finisedtime))")
                    Slider(value: $finisedtime, in: 15...150, step: 1)
                }
                Toggle("Win?", isOn:  $favorite)
            }
            .navigationBarTitle(editCountry == nil ? "新增對戰紀錄" : "Edit Country")
            .navigationBarItems(trailing: Button("save"){
                let champion = Country(champion: self.champion, champion2: self.champion2, selectedPosition: self.selectedPosition, finisedtime: Int(self.finisedtime), times: self.times, favorite: self.favorite)
                if let editCountry = self.editCountry{
                    let index = self.champsData.countries.firstIndex{
                        $0.id == editCountry.id
                    }!      // 因為必有值，所以用驚嘆號
                    self.champsData.countries[index] = champion
                } else{
                    self.champsData.countries.insert(champion, at: 0)
                }
                self.presentationMode.wrappedValue.dismiss()
            }.disabled(disableForm))
       
                .onAppear{
                    if let editCountry = self.editCountry, self.champion == "" {
                        self.champion = editCountry.champion
                        self.selectedPosition = editCountry.selectedPosition
                        self.champion2=editCountry.champion2
                        self.times = editCountry.times
                        self.finisedtime = CGFloat(editCountry.finisedtime)
                        self.favorite = editCountry.favorite
                    }
        }
    }
}

struct ChampionList: View {
    @ObservedObject var champsData = ChampionData()
    @State private var show = false
    var body: some View {
        NavigationView {
            List {
                ForEach(champsData.countries){ (champion) in
                    NavigationLink(destination: CountryEditor(champsData:  self.champsData, editCountry: champion)) {
                        CountryRow(country1: champion)
                    }
                }
                .onMove { (indexSet, index) in
                    self.champsData.countries.move(fromOffsets: indexSet,
                                    toOffset: index)
                }
                .onDelete{ (index) in
                    self.champsData.countries.remove(atOffsets: index)
                }
            }
            .navigationBarTitle("LOL英雄對戰紀錄")
            .navigationBarItems(leading: EditButton().accentColor(.purple), trailing: Button(action: {
                    self.show = true
                },label: {
                    Image(systemName: "plus.circle.fill")
                        .accentColor(.purple)
                    }))
                .sheet(isPresented: $show){
                    NavigationView {
                        CountryEditor(champsData: self.champsData) // 新增時不用修改
                    }
            }
        }
    }
}

struct CountryRow: View {
    var country1: Country
    var body: some View {
        HStack {
            Image("\(country1.champion)")
                .resizable()
                .scaledToFit()
                .frame(width:20)
            Text("\(country1.champion) / \(country1.selectedPosition) / \(country1.champion2)")
            Spacer()
            Text("\(country1.finisedtime) mins")
            Image(systemName: country1.favorite ? "crown.fill": "hand.thumbsdown.fill")
        }
    }
}

struct PieChart: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        Path { (path) in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            path.move(to: center)
            path.addArc(center: center, radius: rect.midX, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
}

struct PieChartView: View {
    var percentages:[Double]?
    var angles: [Angle]
    
    init(percentages: [Double]){
        var sum: Double = 0
        var finalpercentage: [Double] = [0,0,0,0,0,0,0]
        for i in 0..<5 {
         sum = sum + percentages[i]
        }
        
        for j in 0..<5 {
            finalpercentage[j] = percentages[j] / sum
        }
        
        angles = [Angle]()
        var startDegree: Double = 0
        for percentage in finalpercentage {
            angles.append(.degrees(startDegree))
            startDegree += 360 * percentage
        }
    }
    
    var body: some View {
        ZStack {
            PieChart(startAngle: self.angles[0], endAngle: self.angles[1])
                .fill(Color.red)
            PieChart(startAngle: self.angles[1], endAngle: self.angles[2])
                .fill(Color.orange)
            PieChart(startAngle: self.angles[2], endAngle: self.angles[3])
                .fill(Color.yellow)
            PieChart(startAngle: self.angles[3], endAngle: self.angles[4])
                .fill(Color.green)
            PieChart(startAngle: self.angles[4], endAngle: self.angles[5])
                .fill(Color.blue)
            PieChart(startAngle: self.angles[5], endAngle: self.angles[6])
                .fill(Color(hue: 0.627, saturation: 1.0, brightness: 1.0))
            PieChart(startAngle: self.angles[6], endAngle: self.angles[0])
                .fill(Color.purple)
        }.frame(width: 300, height: 300)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
