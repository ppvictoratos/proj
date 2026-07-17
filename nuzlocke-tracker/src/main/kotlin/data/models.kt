package com.shneakypete.nuzlocke.data

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.LocalDateTime

@Entity(tableName = "runs")
data class NuzlockeRun(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val gameName: String,
    val startedAt: LocalDateTime,
    val status: RunStatus = RunStatus.IN_PROGRESS,
    val notes: String = ""
)

@Entity(tableName = "team_members")
data class TeamMember(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val runId: Long,
    val pokemonName: String,
    val species: String,
    val level: Int,
    val caughtAt: String,
    val status: MemberStatus = MemberStatus.ALIVE,
    val dateOfDeath: LocalDateTime? = null
)

enum class RunStatus {
    IN_PROGRESS,
    COMPLETED,
    LOST
}

enum class MemberStatus {
    ALIVE,
    DEAD,
    RELEASED,
    RETIRED
}
