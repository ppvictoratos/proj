import SwiftUI
import CoreData

struct TodayView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\Exercise.date, order: .reverse)],
        predicate: NSPredicate(
            format: "date >= %@ AND date < %@",
            Calendar.current.startOfDay(for: Date()) as NSDate,
            Calendar.current.date(byAdding: .day, value: 1,
                to: Calendar.current.startOfDay(for: Date()))! as NSDate
        )
    )
    private var todayExercises: FetchedResults<Exercise>

    @State private var exerciseType = ""
    @State private var weight = ""
    @State private var duration = ""
    @State private var notes = ""
    @State private var showingForm = false

    var body: some View {
        NavigationStack {
            ZStack {
                HPTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerCard
                        if showingForm { formCard }
                        loggedList
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingForm.toggle()
                    } label: {
                        Image(systemName: showingForm ? "xmark" : "plus")
                            .foregroundColor(HPTheme.neon)
                            .font(.title3)
                    }
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                .font(HPTheme.mono)
                .foregroundColor(HPTheme.neon)

            Text("\(todayExercises.count) logged")
                .font(HPTheme.monoSmall)
                .foregroundColor(HPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(HPTheme.cardBG)
        .cornerRadius(12)
    }

    private var formCard: some View {
        VStack(spacing: 12) {
            Text("LOG EXERCISE")
                .font(HPTheme.monoSmall)
                .foregroundColor(HPTheme.neon)
                .frame(maxWidth: .infinity, alignment: .leading)

            HPTextField(placeholder: "Type (e.g. Bench Press)", text: $exerciseType)
            HPTextField(placeholder: "Weight (kg)", text: $weight)
                .keyboardType(.decimalPad)
            HPTextField(placeholder: "Duration (min)", text: $duration)
                .keyboardType(.numberPad)
            HPTextField(placeholder: "Notes", text: $notes)

            Button(action: saveExercise) {
                Text("SAVE")
                    .font(HPTheme.mono)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(exerciseType.isEmpty ? HPTheme.neonDim : HPTheme.neon)
                    .cornerRadius(8)
            }
            .disabled(exerciseType.isEmpty)
        }
        .padding()
        .background(HPTheme.cardBG)
        .cornerRadius(12)
    }

    private var loggedList: some View {
        VStack(alignment: .leading, spacing: 8) {
            if todayExercises.isEmpty {
                Text("No exercises logged today")
                    .font(HPTheme.monoSmall)
                    .foregroundColor(HPTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ForEach(todayExercises) { exercise in
                    ExerciseRow(exercise: exercise)
                }
            }
        }
    }

    private func saveExercise() {
        let ex = Exercise(context: ctx)
        ex.id = UUID()
        ex.date = Date()
        ex.type = exerciseType.trimmingCharacters(in: .whitespaces)
        ex.weight = Double(weight) ?? 0
        ex.duration = Int32(duration) ?? 0
        ex.notes = notes.isEmpty ? nil : notes

        try? ctx.save()

        exerciseType = ""
        weight = ""
        duration = ""
        notes = ""
        showingForm = false
    }
}

struct HPTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(HPTheme.mono)
            .foregroundColor(HPTheme.textPrimary)
            .padding(10)
            .background(Color(white: 0.12))
            .cornerRadius(6)
            .tint(HPTheme.neon)
    }
}

struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.type)
                    .font(HPTheme.mono)
                    .foregroundColor(HPTheme.textPrimary)

                if let notes = exercise.notes, !notes.isEmpty {
                    Text(notes)
                        .font(HPTheme.monoSmall)
                        .foregroundColor(HPTheme.textSecondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(exercise.formattedWeight)
                    .font(HPTheme.mono)
                    .foregroundColor(HPTheme.neon)

                Text(exercise.formattedDuration)
                    .font(HPTheme.monoSmall)
                    .foregroundColor(HPTheme.textSecondary)
            }
        }
        .padding()
        .background(HPTheme.cardBG)
        .cornerRadius(12)
    }
}
