#include "WindowMac.h"
#include "UtilLog.h"

#if defined(RUSH_PLATFORM_MAC)

using namespace Rush;

@interface WindowMacInternal : NSObject<NSWindowDelegate>
{
	uint32_t windowCount;
}

+ (WindowMacInternal*)sharedDelegate;
- (id)init;
- (void)windowCreated:(NSWindow*)window;
- (void)windowWillClose:(NSNotification*)notification;
- (BOOL)windowShouldClose:(NSWindow*)window;
- (void)windowDidResize:(NSNotification*)notification;
- (void)windowDidBecomeKey:(NSNotification *)notification;
- (void)windowDidResignKey:(NSNotification *)notification;

@end

@implementation WindowMacInternal

+ (WindowMacInternal*)sharedDelegate
{
	static id windowDelegate = [WindowMacInternal new];
	return windowDelegate;
}

- (id)init
{
	self = [super init];
	if (nil == self)
	{
		return nil;
	}

	self->windowCount = 0;
	return self;
}

- (void)windowCreated:(NSWindow*)window
{
	RUSH_ASSERT(window);

	[window setDelegate:self];

	RUSH_ASSERT(self->windowCount < ~0u);
	self->windowCount += 1;
}

- (void)windowWillClose:(NSNotification*)notification
{
	RUSH_UNUSED(notification);
}

- (BOOL)windowShouldClose:(NSWindow*)window
{
	RUSH_ASSERT(window);

	[window setDelegate:nil];

	RUSH_ASSERT(self->windowCount);
	self->windowCount -= 1;

	if (self->windowCount == 0)
	{
		[NSApp terminate:self];
		return false;
	}

	return true;
}

- (void)windowDidResize:(NSNotification*)notification
{
	RUSH_UNUSED(notification);
}

- (void)windowDidBecomeKey:(NSNotification*)notification
{
    RUSH_UNUSED(notification);
}

- (void)windowDidResignKey:(NSNotification*)notification
{
    RUSH_UNUSED(notification);
}

@end

@interface RushView: NSView
@end

@implementation RushView
- (void)keyDown:(NSEvent *)event
{
	RUSH_UNUSED(event);
}
@end

namespace Rush
{

WindowMac::WindowMac(const WindowDesc& desc)
	: Window(desc)
{
	u32 styleMask = NSWindowStyleMaskTitled
		| NSWindowStyleMaskClosable
		| NSWindowStyleMaskMiniaturizable;

	if (desc.resizable)
	{
		styleMask |= NSWindowStyleMaskResizable;
	}

	NSScreen* mainScreen = [NSScreen mainScreen];


	NSRect screenRect = [mainScreen frame];
	const float centerX = (screenRect.size.width  - (float)desc.width)*0.5f;
	const float centerY = (screenRect.size.height - (float)desc.height)*0.5f;
	NSRect rect = NSMakeRect(centerX, centerY, desc.width, desc.height);

	NSWindow* window = [[NSWindow alloc]
		initWithContentRect:rect
		styleMask:styleMask
		backing:NSBackingStoreBuffered
		defer:YES
	];
	m_nativeWindow = window;

	NSString* appName = [[NSProcessInfo processInfo] processName];
	[window setTitle:appName];
	[window makeKeyAndOrderFront:window];
	[window setAcceptsMouseMovedEvents:YES];
	[window setBackgroundColor:[NSColor blackColor]];
	[[WindowMacInternal sharedDelegate] windowCreated:window];

	RushView* view = [[RushView alloc] init];
	[window setContentView:view];
	[window makeFirstResponder:view];
	[view release];
}

WindowMac::~WindowMac()
{
	[m_nativeWindow close];
}

void* WindowMac::nativeHandle()
{
	return m_nativeWindow;
}

void WindowMac::setCaption(const char* str)
{
	// TODO
}

void WindowMac::setSize(const Tuple2i& size)
{
	// TODO
}

void WindowMac::setPosition(const Tuple2i& position)
{
	// TODO
}

static Key translateKeyMac(const NSEvent* event)
{
	NSString* key = [event charactersIgnoringModifiers];
	if ([key length] == 0)
	{
		return Key_Unknown;
	}

	unichar firstChar = [key characterAtIndex:0];
	switch(firstChar)
	{
		case ' ':				return Key_Space;
		case '\'':				return Key_Apostrophe;
		case ',':				return Key_Comma;
		case '-':				return Key_Minus;
		case '.':				return Key_Period;
		case '/':				return Key_Slash;
		case '0': 				return Key_0;
		case '1': 				return Key_1;
		case '2': 				return Key_2;
		case '3': 				return Key_3;
		case '4': 				return Key_4;
		case '5': 				return Key_5;
		case '6': 				return Key_6;
		case '7': 				return Key_7;
		case '8': 				return Key_8;
		case '9': 				return Key_9;
		case ';':				return Key_Semicolon;
		case '=':				return Key_Equal;
		case 'A':
		case 'a': 				return Key_A;
		case 'B':
		case 'b': 				return Key_B;
		case 'C':
		case 'c': 				return Key_C;
		case 'D':
		case 'd': 				return Key_D;
		case 'E':
		case 'e': 				return Key_E;
		case 'F':
		case 'f': 				return Key_F;
		case 'G':
		case 'g': 				return Key_G;
		case 'H':
		case 'h': 				return Key_H;
		case 'I':
		case 'i': 				return Key_I;
		case 'J':
		case 'j': 				return Key_J;
		case 'K':
		case 'k': 				return Key_K;
		case 'L':
		case 'l': 				return Key_L;
		case 'M':
		case 'm': 				return Key_M;
		case 'N':
		case 'n': 				return Key_N;
		case 'O':
		case 'o': 				return Key_O;
		case 'P':
		case 'p': 				return Key_P;
		case 'Q':
		case 'q': 				return Key_Q;
		case 'R':
		case 'r': 				return Key_R;
		case 'S':
		case 's': 				return Key_S;
		case 'T':
		case 't': 				return Key_T;
		case 'U':
		case 'u': 				return Key_U;
		case 'V':
		case 'v': 				return Key_V;
		case 'W':
		case 'w': 				return Key_W;
		case 'X':
		case 'x': 				return Key_X;
		case 'Y':
		case 'y': 				return Key_Y;
		case 'Z':
		case 'z': 				return Key_Z;
		case '[':				return Key_LeftBracket;
		case '\\':				return Key_Backslash;
		case ']':				return Key_RightBracket;
		case NSRightArrowFunctionKey: 			return Key_Right;
		case NSLeftArrowFunctionKey: 			return Key_Left;
		case NSDownArrowFunctionKey: 			return Key_Down;
		case NSUpArrowFunctionKey: 				return Key_Up;
		case NSF1FunctionKey: 				return Key_F1;
		case NSF2FunctionKey: 				return Key_F2;
		case NSF3FunctionKey: 				return Key_F3;
		case NSF4FunctionKey: 				return Key_F4;
		case NSF5FunctionKey: 				return Key_F5;
		case NSF6FunctionKey: 				return Key_F6;
		case NSF7FunctionKey: 				return Key_F7;
		case NSF8FunctionKey: 				return Key_F8;
		case NSF9FunctionKey: 				return Key_F9;
		case NSF10FunctionKey: 				return Key_F10;
		case NSF11FunctionKey: 				return Key_F11;
		case NSF12FunctionKey: 				return Key_F12;
		default:						return Key_Unknown;
	};
}

bool WindowMac::processEvent(NSEvent* event)
{
	NSEventType eventType = [event type];
	switch (eventType)
	{
		case NSEventTypeMouseMoved:
			//Log::message("NSMouseMoved");
			return false;
		case NSEventTypeLeftMouseDragged:
			//Log::message("NSLeftMouseDragged");
			return false;
		case NSEventTypeRightMouseDragged:
			//Log::message("NSRightMouseDragged");
			return false;
		case NSEventTypeOtherMouseDragged:
			//Log::message("NSOtherMouseDragged");
			return false;
		case NSEventTypeLeftMouseDown:
			//Log::message("NSLeftMouseDown");
			return false;
		case NSEventTypeLeftMouseUp:
			//Log::message("NSLeftMouseUp");
			return false;
		case NSEventTypeRightMouseDown:
			//Log::message("NSRightMouseDown");
			return false;
		case NSEventTypeRightMouseUp:
			//Log::message("NSRightMouseUp");
			return false;
		case NSEventTypeOtherMouseDown:
			//Log::message("NSOtherMouseDown");
			return false;
		case NSEventTypeOtherMouseUp:
			//Log::message("NSOtherMouseUp");
			return false;
		case NSEventTypeScrollWheel:
			//Log::message("NSScrollWheel");
			return false;
		case NSEventTypeKeyDown:
		{
			Key key = translateKeyMac(event);
			m_keyboard.keys[key] = true;
			auto e = WindowEvent::KeyDown(key);
			broadcast(e);
			return true;
		}
		case NSEventTypeKeyUp:
		{
			Key key = translateKeyMac(event);
			m_keyboard.keys[key] = false;
			auto e = WindowEvent::KeyUp(key);
			broadcast(e);
			return true;
		}
		case NSEventTypeFlagsChanged:
		{
			u16 keyCode = [event keyCode];

			Key key = Key_Unknown;
			switch(keyCode)
			{
			case 56:
				key = Key_LeftShift;
				break;
			case 60:
				key = Key_RightShift;
				break;
			case 59:
				key = Key_LeftControl;
				break;
			default:
				key = Key_Unknown;
				break;
			}

			if (key != Key_Unknown)
			{
				if (m_keyboard.keys[key])
				{
					auto e = WindowEvent::KeyUp(key);
					broadcast(e);
					m_keyboard.keys[key] = false;
				}
				else
				{
					auto e = WindowEvent::KeyDown(key);
					broadcast(e);
					m_keyboard.keys[key] = true;
				}
			}

			return true;
		}
		default:
			//Log::message("Unhandled event type");
			return false;
	}
}

}

#endif
