//
//  LeaderboardView.swift
//  CrossyRoads
//
//  Created by Mykyta Kurochka on 02.02.2025.
//

import SwiftUI

struct LeaderboardView: View {
    var players: [Player]
    var body: some View {
        VStack {
            Text("Leaderboard")
                .font(.headline)
                .foregroundStyle(Color.white)
                .padding(.bottom, 5)
            ScrollView {
                ForEach(players) { player in
                    HStack {
                        Text(player.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.white)
                        Text("\(player.score)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(Color.white)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    LeaderboardView(players: [Player(score: 30),Player(score: 28),Player(score: 20)])
}
