/*
* Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*	*	Redistributions of source code must retain the above copyright notice, this
*		list of conditions and the following disclaimer.
*
*	*	Redistributions in binary form must reproduce the above copyright notice,
*		this list of conditions and the following disclaimer in the documentation
*		and/or other materials provided with the distribution.
*
*	*	Neither the name of CosmicMind nor the names of its
*		contributors may be used to endorse or promote products derived from
*		this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit

public typealias AnimationFillModeType = String

@objc public enum AnimationFillMode: Int {
	case forwards
	case backwards
	case both
	case removed
}

/**
	:name:	AnimationFillModeToValue
*/
public func AnimationFillModeToValue(mode: AnimationFillMode) -> AnimationFillModeType {
	switch mode {
	case .forwards:
		return kCAFillModeForwards
	case .backwards:
		return kCAFillModeBackwards
	case .both:
		return kCAFillModeBoth
	case .removed:
		return kCAFillModeRemoved
	}
}

public typealias AnimationDelayCancelBlock = (cancel : Bool) -> Void

public struct Animation {
	/// Delay helper method.
	public static func delay(time: TimeInterval, completion: ()-> Void) ->  AnimationDelayCancelBlock? {
		
		func dispatch_later(completion: ()-> Void) {
			DispatchQueue.main.after(when: DispatchTime.now() + time, execute: completion)
        }
		
		var cancelable: AnimationDelayCancelBlock?
		
		let delayed: AnimationDelayCancelBlock = { (cancel: Bool) in
			if !cancel {
				DispatchQueue.main.async(execute: completion)
			}
			cancelable = nil
		}
		
		cancelable = delayed
		
		dispatch_later {
			cancelable?(cancel: false)
		}
		
		return cancelable;
	}
	
	/**
	:name:	delayCancel
	*/
	public static func delayCancel(completion: AnimationDelayCancelBlock?) {
		completion?(cancel: true)
	}

	
	/**
	:name:	animationDisabled
	*/
	public static func animationDisabled(animations: (() -> Void)) {
		animateWithDuration(duration: 0, animations: animations)
	}
	
	/**
	:name:	animateWithDuration
	*/
	public static func animateWithDuration(duration: CFTimeInterval, animations: (() -> Void), completion: (() -> Void)? = nil) {
		CATransaction.begin()
		CATransaction.setAnimationDuration(duration)
		CATransaction.setCompletionBlock(completion)
		CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
		animations()
		CATransaction.commit()
	}
	
	/**
	:name:	animationGroup
	*/
	public static func animationGroup(animations: [CAAnimation], duration: CFTimeInterval = 0.5) -> CAAnimationGroup {
		let group: CAAnimationGroup = CAAnimationGroup()
		group.fillMode = AnimationFillModeToValue(mode: .forwards)
		group.isRemovedOnCompletion = false
		group.animations = animations
		group.duration = duration
		group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		return group
	}
	
	/**
	:name:	animateWithDelay
	*/
	public static func animateWithDelay(delay d: CFTimeInterval, duration: CFTimeInterval, animations: (() -> Void), completion: (() -> Void)? = nil) {
		_ = delay(time: d) {
			animateWithDuration(duration: duration, animations: animations, completion: completion)
		}
	}
}
