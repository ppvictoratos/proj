import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\Exercise.date, order: .reverse)],
        predicate: weekPredicate()
    )
    private var weekExercises: FetchedResults<Exercise>

    var body: some View {
        NavigationStack {
            ZStack {
                HPTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        completionCard
                        streakCard
                        weekBreakdown
                    }
                    .padding()
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var completionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THIS WEEK")
                .font(HPTheme.monoSmall)
                .foregroundColor(HPTheme.neon)

            HStack(spacing: 24) {
                StatBlock(value: "\(gymCount)/4", label: "GYM")
                StatBlock(value: "\(swimCount)/2", label: "SWIM")
                StatBlock(value: "\(totalCount)", label: "TOTAL")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(HPTheme.cardBG)
        .cornerRadius(12)
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STREAK")
                .font(HPTheme.monoSmall)
                .foregroundColor(HPTheme.neon)

            HStack(spacing: 24) {
                StatBlock(value: "\(streak)", label: "DAYS")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(HPTheme.cardBG)
        .cornerRadius(12)
    }

    private var weekBreakdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BREAKDOWN")
                .font(HPTheme.monoSmall)
                .foregroundColor(HPTheme.neon)
                .padding(.bottom, 4)

            ForEach(exercisesByType, id: \.type) { group in
                HStack {
                    Text(group.type)
                        .font(HPTheme.mono)
                        .foregroundColor(HPTheme.textPrimary)
                    Spacer()
                    Text("\(group.count)x")
                        .font(HPTheme.mono)
                        .foregroundColor(HPTheme.neon)
                }
            }

            if exercisesByType.isEmpty {
                Text("No data this week")
                    .font(HPTheme.monoSmall)
                    .foregroundColor(HPTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(HPTheme.cardBG)
        .cornerRadius(12)
    }

    private var gymCount: Int {
        daysWithExerciseMatching { type in
            !type.lowercased().contains("swim")
            && !type.lowercased().contains("freestyle")
            && !type.lowercased().contains("backstroke")
        }
    }

    private var swimCount: Int {
        daysWithExerciseMatching { type in
            type.lowercased().contains("swim")
            || type.lowercased().contains("freestyle")
            || type.lowercased().contains("backstroke")
        }
    }

    private var totalCount: Int { weekExercises.count }

    private func daysWithExerciseMatching(_ predicate: (String) -> Bool) -> Int {
        let cal = Calendar.current
        var days = Set<Int>()
        for ex in weekExercises where predicate(ex.type) {
            days.insert(cal.ordinality(of: .day, in: .year, for: ex.date) ?? 0)
        }
        return days.count
    }

    private var streak: Int {
        let cal = Calendar.current
        var count = 0
        var checkDate = cal.startOfDay(for: Date())

        while true {
            let nextDay = cal.date(byAdding: .day, value: 1, to: checkDate)!
            let req = NSFetchRequest<Exercise>(entityName: "Exercise")
            req.predicate = NSPredicate(
                format: "date >= %@ AND date < %@",
                checkDate as NSDate, nextDay as NSDate
            )
            let dayCount = (try? ctx.count(for: req)) ?? 0

            if dayCount > 0 {
                count += 1
                checkDate = cal.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return count
    }

    private var exercisesByType: [(type: String, count: Int)] {
        var counts: [String: Int] = [:]
        for ex in weekExercises {
            counts[ex.type, default: 0] += 1
        }
        return counts.map { (type: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private static func weekPredicate() -> NSPredicate {
        let cal = Calendar.current
        let now = Date()
        let weekday = cal.component(.weekday, from: now)
        let daysFromMonday = (weekday + 5) % 7
        let monday = cal.date(byAdding: .day, value: -daysFromMonday,
                              to: cal.startOfDay(for: now))!
        let nextMonday = cal.date(byAdding: .day, value: 7, to: monday)!
        return NSPredicate(format: "date >= %@ AND date < %@",
                           monday as NSDate, nextMonday as NSDate)
    }
}

struct StatBlock: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(HPTheme.monoLarge)
                .foregroundColor(HPTheme.textPrimary)
            Text(label)
                .font(HPTheme.monoSmall)
                .foregroundColor(HPTheme.textSecondary)
        }
    }
}
