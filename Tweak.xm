const static float defaultDecelerationRate = 0.998000f;
const static CGSize defaultDecelerationFactor = CGSizeMake(defaultDecelerationRate, defaultDecelerationRate);

//static bool tweakIsEnabled = YES;

static const float velocityToBeginDecel = 1.0f;

static CGSize decelFactorAtVelocity(float startDecel, float endDecel, float velocityToBeginDecel, double velocity) {
	//Increase deceleration linearly as velocity decreases for smooth deceleration
	float decel = ((startDecel - endDecel)/velocityToBeginDecel) * velocity + endDecel;
	return CGSizeMake(decel, decel);
}

%hook UITableView

-(void)_smoothScrollWithUpdateTime:(double)arg1 {
	%orig;

	double velocity = fabs(MSHookIvar<double>(self, "_verticalVelocity"));

	if(velocity < 0.1f) {//Prevent scroller from crawling
		MSHookIvar<double>(self, "_verticalVelocity") = 0.0;
	}
	else if(velocity < 0.25f) {
		MSHookIvar<CGSize>(self, "_decelerationFactor") = decelFactorAtVelocity(0.995375f, 0.98f, 0.25, velocity);
	}
	else if(velocity < velocityToBeginDecel) {
		MSHookIvar<CGSize>(self, "_decelerationFactor") = decelFactorAtVelocity(defaultDecelerationRate, 0.9945f, velocityToBeginDecel, velocity);
	}
}

-(void)_scrollViewDidEndDraggingWithDeceleration:(bool)arg1 {
	%orig;

	//Reset deceleration to default after every swipe
	MSHookIvar<CGSize>(self, "_decelerationFactor") = defaultDecelerationFactor;
}

%end

%ctor {
	%init;
}
