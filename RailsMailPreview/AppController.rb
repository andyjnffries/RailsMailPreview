#
#  AppController.rb
#  RailsMailPreview
#
#  Created by Fernando Barajas on 8/12/11.
#  Copyright 2011 Fernando Barajas. All rights reserved.
#


class AppController < NSWindowController
  attr_accessor :splitview
  attr_accessor :bottomViewController
  attr_accessor :toolbarViewController
  attr_accessor :sidePanelViewController
  attr_accessor :contentSplitView
  attr_accessor :htmlview
  attr_accessor :plainview
  attr_accessor :contentTabView

  def didFinishLaunching
    setup_toolbar
    setup_side_views
    setup_left_panel
    setup_notification
  end

  def window(aWindow, willPositionSheet:sheet, usingRect:rect)
    newRect = rect
    newRect.origin.y -= 18.0
    newRect
  end

  def setup_notification
    center = NSDistributedNotificationCenter.defaultCenter
    center.addObserver(self,
                       selector: :"receiveNotification:",
                       name: "RailsMailPreview.email",
                       object: nil)

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                selector: :"tabItemDidChangeNotification:",
                                                    name: "FBTabViewItemDidChange",
                                                  object: nil)

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: :"receiveDidLoadHTMLString:",
                                                   name: "loadHTMLString",
                                                   object: nil)

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: :"receiveSaveNewMessage:",
                                                   name: "saveNewMessage",
                                                   object: nil)
  end

  def tabItemDidChangeNotification(notification)
    selectedTabIndex = notification.object.itemIndex
    @contentTabView.selectTabViewItemAtIndex(selectedTabIndex)
  end

  def didReceiveNewMessage
    NSApplication.sharedApplication.setSupressNextAttention(YES)
    @progressWindow ||= FBProgressWindowController.alloc.init
    NSApplication.sharedApplication.beginSheet(@progressWindow.window,
                                              modalForWindow: self.window,
                                              modalDelegate: self,
                                              didEndSelector: nil,
                                              contextInfo: nil)
  end

  def didFinishReceivingNewMessage
    NSApplication.sharedApplication.endSheet(@progressWindow.window)
    @progressWindow.window.orderOut(self)
  end

  def receiveNotification(aNotification)
    self.didReceiveNewMessage
    queue = Dispatch::Queue.new('net.fernyb.RailsMailPreview.gcd')
    queue.async do
      msg = aNotification.object
      mail = Mail.new(msg)
      self.performSelectorOnMainThread(:"set_mail_message:", withObject:mail, waitUntilDone:YES)
    end
  end

  def set_mail_message(mail)
    @sidePanelViewController.saveNewMessage(mail)
  end

  def receiveSaveNewMessage(notification)
    self.didFinishReceivingNewMessage
    self.receiveDidLoadHTMLString(notification)
    self.show_left_panel
  end

  def receiveDidLoadHTMLString(notification)
    if self.contentTabView.isHidden
      @startup_view.setHidden(YES) if @startup_view
      self.contentTabView.setHidden(NO)
    end
  end

  def setup_startup_view
    self.contentTabView.setHidden(YES)

    @startup_view = FBStartupView.alloc.initWithFrame([0,0, CGRectGetWidth(self.contentTabView.superview.frame), CGRectGetHeight(self.contentTabView.superview.frame)])
    if !Message.first
      self.hide_left_panel(animate:NO)
      @startup_view.message = "No Messages Available"
    else
      @startup_view.message = "No Message Selected"
    end

    self.contentTabView.superview.addSubview(@startup_view.render)
  end

  def setup_side_views
    # Setup the left view
    @htmlview = FRBSideView.alloc.initWithFrame(
      [0,0, CGRectGetWidth(@contentTabView.frame), CGRectGetHeight(@contentTabView.frame)]
    )
    @htmlview.view_type = :html

    # Setup the right view
    @plainview = FRBSideView.alloc.initWithFrame(
      [0,0, CGRectGetWidth(@contentTabView.frame), CGRectGetHeight(@contentTabView.frame)]
    )
    @plainview.view_type = :text

    htmlTabItem = @contentTabView.tabViewItemAtIndex(0)
    textTabItem = @contentTabView.tabViewItemAtIndex(1)

    htmlTabItem.setView(@htmlview)
    textTabItem.setView(@plainview)

    @contentTabView.selectTabViewItemAtIndex(0)
  end

  def setup_toolbar
    self.window.setTitleBarHeight(40.0)
    @toolbarViewController = FBToolbarViewController.alloc.init
    @toolbarViewController.parentController = self
    self.window.setTitleBarView(@toolbarViewController.view)
  end

  def animationDuration
    0.16
  end

  def toggle_left_panel
    panelview = @contentSplitView.subviews.first
    if CGRectGetWidth(panelview.frame) <= 1
      self.show_left_panel
    else
      self.hide_left_panel
    end
  end

  def show_left_panel
    panelview = @contentSplitView.subviews.first
    if CGRectGetWidth(panelview.frame) <= 1
      NSAnimationContext.beginGrouping
      NSAnimationContext.currentContext.setDuration(self.animationDuration)
      if @prevContentSplitViewFrame
        panelview.animator.setFrame(@prevContentSplitViewFrame)
      else
        panelview.animator.setFrame([0,0, 300, CGRectGetHeight(panelview.frame)])
      end
      NSAnimationContext.endGrouping
    end
  end

  def hide_left_panel(opts={})
    panelview = @contentSplitView.subviews.first
    @prevContentSplitViewFrame = panelview.frame
    if opts[:animate] == NO
      panelview.setFrameSize([0.0, CGRectGetHeight(panelview.frame)])
    else
      NSAnimationContext.beginGrouping
      NSAnimationContext.currentContext.setDuration(self.animationDuration)
      panelview.animator.setFrameSize([0.0, CGRectGetHeight(panelview.frame)])
      NSAnimationContext.endGrouping
    end
  end

  def setup_left_panel
    if @sidePanelViewController.nil?
      @sidePanelViewController = FBSidePanelViewController.alloc.init
      @sidePanelViewController.htmlview = @htmlview
      @sidePanelViewController.plainview = @plainview
      @contentSplitView.subviews.first.removeFromSuperview
      @contentSplitView.addSubview(@sidePanelViewController.view,
                              positioned: NSWindowBelow,
                              relativeTo: @contentSplitView.subviews.first)
      @contentSplitView.setDelegate(self)
      self.setup_startup_view
    end
  end

  def toggle_rotate_view
  #   leftview = @splitview.subviews.first

  #   @splitview.subviews.first.removeFromSuperview
  #   @splitview.subviews.last.removeFromSuperview

  #   if leftview.view_type == :html
  #     @splitview.addSubview(@plainview)
  #     @splitview.addSubview(@htmlview)
  #   else
  #     @splitview.addSubview(@htmlview)
  #     @splitview.addSubview(@plainview)
  #   end
  #   @splitview.adjustSubviews
  end

  def toggle_horizontal_view
    # @splitview.setVertical(!@splitview.isVertical)
    # @splitview.setNeedsDisplay(YES)
    # @splitview.adjustSubviews
  end

  # - (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
  def splitView(aSplitView, constrainMaxCoordinate:proposedMax, ofSubviewAt:dividerIndex)
    if dividerIndex == 0
      350
    else
      proposedMax
    end
  end

  # - (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
  def splitView(aSplitView, constrainMinCoordinate:proposedMin, ofSubviewAt:dividerIndex)
    if dividerIndex == 0
      150
    else
      proposedMin
    end
  end

  # - (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
  def splitView(aSplitView, shouldAdjustSizeOfSubview:subview)
   subview.className != "FBSidePanelView"
  end
end
