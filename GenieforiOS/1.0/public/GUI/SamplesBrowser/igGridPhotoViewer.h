#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <IG/IG.h>
#import "DLNACore.h"
#import "DLNAGolbal.h"

@class DLNACenter;
@class DLNAServerList;

@interface igGridPhotoViewer : UIViewController<IGGridViewDelegate,UIAlertViewDelegate>
{
    IGGridView* _photoGridView;
    IGGridViewSingleRowSingleFieldDataSourceHelper* _photoDS;
    
    IGGridView* _thumbsGridView;
    IGGridViewSingleFieldMultiColumnDataSourceHelper* _thumbsDS;
    IGGridViewSingleRowSingleFieldDataSourceHelper* _singleRowThumbDS;
    
    NSMutableArray* _photos;
    NSMutableArray* _thumbs;
    
    UIView* _resizeThumb;
    CGPoint _originPoint;
    
    
    int _numberOfColumns, _maxNumberOfColumns, _portraitColumnCount;
    CGFloat _columnSize, _resizeThumbSize, _resizeThumbOffset;
    
    IGCellPath* _editPath;
    CGSize _landscapeSize, _portraitSize;
    
    deejay::DLNAObjectList    * m_objList;
    DLNACenter                * delegate;
    DLNAServerList            * serverList;
    NSString                  * m_path; //图片存放的路径
    NSInteger                 m_index;  //记录当前图片的序号
    NSInteger                 m_count;  //统计换页的次数
    BOOL                      m_loaded; //是否已经加载
    BOOL                      m_updata; //是否需要更新
    BOOL                      m_first;  //是否是第一次显示
    NSInteger                 m_imageIndex;
    NSInteger                 m_imgCount;
    UIAlertView*              m_alert;
    BOOL                      m_zero;
    BOOL                      m_setvalue;
}
-(void)getImageSourceList:(deejay::DLNAObjectList*)imagesourceList;
-(void)loadImage:(NSInteger)imgeCount;
-(void)ChangeImagePath:(const deejay::DLNAItem*) mediaItem;
-(void)getCurrentImage;
-(void)loadAnotherImage;
-(void)getSourceIndex:(NSInteger)index;
-(void)WaitMessageDialogShow;

-(void)updateDataForOrientation:(BOOL)isLandscape;
-(void)updateLayoutForOrientation:(UIInterfaceOrientation)interfaceOrientation usingDuration:(NSTimeInterval)duration;

@end

@interface PhotoInfo : NSObject

@property(nonatomic, retain)NSString* imagePath;
@property(nonatomic, retain)NSString* thumbPath;
@property(nonatomic, readonly)UIImage* image;
@property(nonatomic, readonly)UIImage* thumb;
@property(nonatomic, retain)NSData* imageData;
@property(nonatomic, retain)NSData* thumbData;

@end


//2013-01-16
@interface UIImage(UIImageScale)
-(UIImage*)scaleToSize:(CGSize)size;
@end

