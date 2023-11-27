//
//  ImageLoadingAnimation.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 27/11/2023.
// source: https://www.youtube.com/watch?v=oihbs1tYqkE&ab_channel=ShubhamSingh

import SwiftUI

struct ImageLoadingAnimation: View {
    let width: CGFloat
    let height: CGFloat
    
    // Loading animation
    @State var isAnimating = false
    @State var circleStart: CGFloat = 0.17
    @State var circleEnd: CGFloat = 0.325
    
    @State var rotationDegree: Angle = .degrees(0)
    
    let background: Color = Color(UIColor.systemBackground)
    let label: Color = Color(UIColor.label)
    
    let circleTrackGradient = LinearGradient(colors: [.circleTrackStart.opacity(0.2), .circleTrackEnd.opacity(0.2)], startPoint: .top, endPoint: .bottom)
    let circleFillGradient = LinearGradient(colors: [.circleRoundStart, .circleRoundEnd], startPoint: .topLeading, endPoint: .trailing)
    
    let trackerRotation: Double = 3 // spins 3 times
    let animationDuration: Double = 0.75
    
    var body: some View {
            ZStack{
                Circle()
                    .stroke(lineWidth: 10) // 20
                    .fill(circleTrackGradient)
                    .shadow(color: label.opacity(0.015), radius: 5, x: 1, y: 1)
                
                Circle()
                    .trim(from: circleStart, to: circleEnd) // 15
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .fill(circleFillGradient)
                    .rotationEffect(rotationDegree)
            }
            .frame(width: width, height: height)
            .onAppear {
                animateLoader()
                
                // loop animation
                Timer.scheduledTimer(withTimeInterval: (trackerRotation * animationDuration) + animationDuration, repeats: true) { _ in
                    self.animateLoader()
                }
            }
        
    }
    
    func getRotationAngle() -> Angle {
        return .degrees(360 * trackerRotation) + .degrees(120)
    }
    
    func animateLoader() {
        withAnimation(.spring(response: animationDuration * 1.1)) {
            rotationDegree = .degrees(-57.5)
            circleEnd = 0.5 // starting point for line
        }
        
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
            withAnimation(.easeInOut(duration: trackerRotation * animationDuration)) {
                self.rotationDegree += self.getRotationAngle()
            }
        }
        
        // expand
        Timer.scheduledTimer(withTimeInterval: animationDuration * 1.1, repeats: false) { _ in
            withAnimation(.easeOut(duration: (trackerRotation * animationDuration) / 2.5)) {
                circleEnd = 0.95
            }
        }
        
        // reset
        Timer.scheduledTimer(withTimeInterval: trackerRotation * animationDuration, repeats: false) { _ in
            rotationDegree = .degrees(47.5)
            withAnimation(.easeOut(duration: animationDuration)) {
                circleEnd = 0.4 // ending a bit smaller
            }
        }
        
    }
}

struct ImageLoadingAnimation_Previews: PreviewProvider {
    static var previews: some View {
        ImageLoadingAnimation(width: 65, height: 65)
    }
}
