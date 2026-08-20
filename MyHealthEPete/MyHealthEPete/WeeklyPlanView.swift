import SwiftUI

struct WeeklyPlanView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                HPTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(WeeklyPlan.days) { day in
                            DayCard(day: day)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Weekly Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct DayCard: View {
    let day: PlannedDay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(day.name)
                    .font(HPTheme.mono)
                    .foregroundColor(HPTheme.neon)

                Spacer()

                if day.isToday {
                    Text("TODAY")
                        .font(HPTheme.monoSmall)
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(HPTheme.neon)
                        .cornerRadius(4)
                }
            }

            if day.isRest {
                Text("Rest")
                    .font(HPTheme.monoSmall)
                    .foregroundColor(HPTheme.textSecondary)
            } else {
                Text(day.routine)
                    .font(HPTheme.monoSmall)
                    .foregroundColor(HPTheme.textPrimary)

                ForEach(day.exercises, id: \.self) { ex in
                    Text("  \(ex)")
                        .font(HPTheme.monoSmall)
                        .foregroundColor(HPTheme.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(day.isToday ? Color(white: 0.12) : HPTheme.cardBG)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(day.isToday ? HPTheme.neon.opacity(0.4) : .clear, lineWidth: 1)
        )
    }
}

struct PlannedDay: Identifiable {
    let id = UUID()
    let name: String
    let routine: String
    let exercises: [String]
    let dayOfWeek: Int

    var isRest: Bool { routine.isEmpty }

    var isToday: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == dayOfWeek
    }
}

enum WeeklyPlan {
    static let days: [PlannedDay] = [
        PlannedDay(name: "MON", routine: "Upper Body Push",
                   exercises: ["Bench Press 4x8", "OHP 3x10", "Incline DB Press 3x10", "Tricep Dips 3x12"],
                   dayOfWeek: 2),
        PlannedDay(name: "TUE", routine: "Swim",
                   exercises: ["Freestyle 20min", "Drills 10min"],
                   dayOfWeek: 3),
        PlannedDay(name: "WED", routine: "Lower Body",
                   exercises: ["Squat 4x6", "RDL 3x10", "Leg Press 3x12", "Calf Raises 4x15"],
                   dayOfWeek: 4),
        PlannedDay(name: "THU", routine: "",
                   exercises: [],
                   dayOfWeek: 5),
        PlannedDay(name: "FRI", routine: "Upper Body Pull",
                   exercises: ["Pull-ups 4x8", "Barbell Row 4x8", "Face Pulls 3x15", "Bicep Curls 3x12"],
                   dayOfWeek: 6),
        PlannedDay(name: "SAT", routine: "Swim",
                   exercises: ["Freestyle 30min", "Backstroke 10min"],
                   dayOfWeek: 7),
        PlannedDay(name: "SUN", routine: "",
                   exercises: [],
                   dayOfWeek: 1),
    ]
}
