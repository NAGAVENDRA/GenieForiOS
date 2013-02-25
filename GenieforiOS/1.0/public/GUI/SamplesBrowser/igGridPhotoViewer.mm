
#import "igGridPhotoViewer.h"
#import <QuartzCore/QuartzCore.h>
#import "GenieHomePageController.h"
#import "DLNACenter.h"
#import "DLNAServerList.h"

@implementation igGridPhotoViewer

- (void)viewDidLoad
{
    BOOL iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    BOOL iPhone5 =  iPhone && ( [ [ UIScreen mainScreen ] bounds ].size.height >= 568 );
    
    //设置小图标的行数
    _numberOfColumns = 1;
    
    _columnSize = iPhone ? 75 : 75;
    _resizeThumbSize = iPhone ? 20 : 50;
    
    //设置小图标最多能显示的行数
    _maxNumberOfColumns = iPhone && !iPhone5 ? 2 : 3;
    
    _portraitColumnCount = iPhone ? 3 : 8;  //设置小图标一行的个数
    _resizeThumbOffset = iPhone ? 10 : 20;
    _landscapeSize = iPhone ? (!iPhone5? CGSizeMake(480, 256) : CGSizeMake(568, 256)) : CGSizeMake(1024, 680);
    _portraitSize = iPhone ? (!iPhone5? CGSizeMake(320, 392): CGSizeMake(320, 480)) : CGSizeMake(768, 935);
    
    
    self.view.frame = CGRectMake(0,0, 320, 480);
    self.view.backgroundColor = [UIColor colorWithWhite:.1 alpha:1];
    
    _thumbsGridView = [[IGGridView alloc]init];
    _thumbsGridView.rowSeparatorHeight = 0;
    _thumbsGridView.delegate = self;
    _thumbsGridView.selectionType = IGGridViewSelectionTypeCell;
    _thumbsGridView.headerHeight = 0;
    _thumbsGridView.rowHeight = _columnSize;
    [self.view addSubview:_thumbsGridView];
    
    
    _photoGridView = [[IGGridView alloc]initWithFrame:self.view.frame style:IGGridViewStyleSingleCellPaging];
    _photoGridView.delegate = self;
    _photoGridView.selectionType = IGGridViewSelectionTypeNone;
    _photoGridView.alwaysBounceVertical = NO;
    _photoGridView.allowHorizontalBounce = YES;
    [self.view addSubview:_photoGridView];
    
    _photos = [[NSMutableArray alloc]init];
    _thumbs = [[NSMutableArray alloc]init];
    
    delegate = [[DLNACenter alloc] init];
    serverList = [[DLNAServerList alloc] init];
    m_count = 0;
    m_updata = NO;
    m_loaded = NO;
    m_first = YES;
    m_setvalue = NO;
    
    [self WaitMessageDialogShow]; 
    [self loadImage:m_imageIndex];
   // [self performSelector:@selector(loadAnotherImage) withObject: nil afterDelay:0.0f];
    
    IGGridViewImageColumnDefinition* col = [[IGGridViewImageColumnDefinition alloc]initWithKey:@"image" forPropertyType:IGGridViewImageColumnDefinitionPropertyTypeImage];
    col.enableZooming = YES;
    
    _photoDS = [[IGGridViewSingleRowSingleFieldDataSourceHelper alloc]initWithField:col];
    _photoDS.data = _photos;
    
    _photoGridView.dataSource = _photoDS;
    
    IGGridViewImageColumnDefinition* thumbCol = [[IGGridViewImageColumnDefinition alloc]initWithKey:@"thumb" forPropertyType:IGGridViewImageColumnDefinitionPropertyTypeImage];
    _thumbsDS   = [[IGGridViewSingleFieldMultiColumnDataSourceHelper alloc]initWithField:thumbCol];
    _thumbsDS.numberOfColumns = 1;
    _thumbsDS.data = _photos;
    _thumbsGridView.dataSource = _thumbsDS;
    
    _singleRowThumbDS = [[IGGridViewSingleRowSingleFieldDataSourceHelper alloc]initWithField:thumbCol];
    _singleRowThumbDS.data = _photos;
    
    [self updateLayoutForOrientation:self.interfaceOrientation usingDuration:0];
    _photos = nil;
    [_photos  release];
    [_thumbs release];
    
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    m_first = YES;
}

-(void)gridView:(IGGridView *)gridView initializeCell:(IGGridViewCell *)cell
{
    if (m_first)
    {
        cell.selectedColor = [UIColor colorWithWhite:.1 alpha:1];
        m_first = NO;
    }
    else
    {
        cell.selectedColor = [UIColor colorWithWhite:1 alpha:.9];
    }
}

//获取图片源
-(void)getImageSourceList:(deejay::DLNAObjectList *)imagesourceList
{
    m_objList = new deejay::DLNAObjectList();
    m_objList = imagesourceList;
    if (m_loaded)
    {
        m_loaded = NO;
        m_updata = YES;
        m_count = 0;
        m_first = YES;
        m_imgCount = m_imageIndex;
        m_alert = nil;
        
        [self WaitMessageDialogShow];
        [self loadAnotherImage];
       // [self performSelector:@selector(loadAnotherImage) withObject: nil afterDelay:0.2f];
    }
}

//根据行来确定选取当前图片
-(void)getCurrentImage
{
    if (m_imgCount + m_index <= m_objList->count())
    {
        deejay::DLNAObject& obj = *(m_objList->itemAt(m_imgCount + m_index));
        [delegate setPlaylist];
        [delegate openMediaObj:obj.asItem()];
    }
}

//将url地址转成字符串
-(void)ChangeImagePath:(const deejay::DLNAItem*) mediaItem
{
    NPT_String iconUrl;
    if (((deejay::DLNAObject*)mediaItem)->findThumbnailURL(200, 200, NULL, iconUrl))
    {
        m_path = [NSString stringWithUTF8String:iconUrl.GetChars()];
    }
}

//加载图片，数量固定为8张
-(void)loadImage:(NSInteger)imgeCount
{
    m_loaded = YES;
    int num = 8;
    if ((m_zero && m_count > 0))
    {
        num = 7;
        m_imgCount = imgeCount - num;
        if (m_imgCount < 0)
        {
            m_imgCount = 0;
            imgeCount = num;
            m_imageIndex = 0;
        }
        for (int j = m_imgCount; j <= imgeCount; j++)
        {
            deejay::DLNAObject& obj = *(m_objList->itemAt(j));
            [self ChangeImagePath:obj.asItem()];
            
            PhotoInfo* photoInfo = [[PhotoInfo alloc]init];
            photoInfo.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:m_path]];
            [_photos addObject:photoInfo];
            [photoInfo release];
        }
        m_count--;
        m_zero = NO;
    }
    else
    {
        if (imgeCount + num >= m_objList->count())
        {
            num = m_objList->count() - imgeCount;
        }
        
        for(int i = imgeCount; i < imgeCount + num; i++)
        {
            deejay::DLNAObject& obj = *(m_objList->itemAt(i));
            [self ChangeImagePath:obj.asItem()];
            
            PhotoInfo* photoInfo = [[PhotoInfo alloc]init];
            photoInfo.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:m_path]];
            [_photos addObject:photoInfo];
            [photoInfo release];
        }
    }
    if (m_alert)
    {
        [m_alert dismissWithClickedButtonIndex:0 animated:YES];
        m_alert = nil;
    }
}

//多次加载
-(void)loadAnotherImage
{
    if (_photos)
    {
        _photos = nil;
    }
    _photos = [[NSMutableArray alloc]init];
    
    [self loadImage:m_imgCount];
    
    _photoDS.data = _photos;
    _photoGridView.dataSource = _photoDS;
    
    _thumbsDS.data = _photos;
    _thumbsGridView.dataSource = _thumbsDS;
    
    _singleRowThumbDS.data = _photos;
    
    if (m_loaded)
    {
        [_photoGridView updateData];
    }
    
    if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [self updateDataForOrientation:YES];
    }
    else
    {
        [self updateDataForOrientation:NO];
    }
    if (m_alert)
    {
        [m_alert dismissWithClickedButtonIndex:0 animated:YES];
        m_alert = nil;
    }
    
    [_photos release];
}

-(void)gridView:(IGGridView *)gridView pageChanged:(IGCellPath *)path
{
    if(_thumbsGridView.dataSource == _thumbsDS)
    {
        path = [_photoDS normalizePath:path];
        path = [_thumbsDS deNormalizePath:path];
    }
    
    //当前选定图片的序号
    if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        m_index = path.rowIndex;
    }
    else
    {
        m_index = path.columnIndex;
    }
    //m_index = path.columnIndex;
    
    [_thumbsGridView selectCellAtPath:path animated:NO scrollPosition:IGGridViewScrollPositionNone];
    [_thumbsGridView scrollToCellAtCellPath:path atScrollPosition:IGGridViewScrollPositionNone animated:YES];
    
    [self gridView:_thumbsGridView didSelectCellAtPath:path];
    
    
    if (![delegate currentRenderIsSelf])
    {
        [self getCurrentImage];
    }
    
    if (m_index > 0)
    {
        m_zero = YES;
    }
    
    //最后一张时往后加载图片
    if (m_index % 7 == 0 && m_index > 0)
    {
        m_count++;
        m_imgCount = m_count * m_index + m_imageIndex;
        
        if (m_imgCount < m_objList->count())
        {
            m_updata = YES;
            [self WaitMessageDialogShow];
            
            [self performSelector:@selector(loadAnotherImage) withObject: nil afterDelay:0.4f];
        }
        m_zero = NO;
    }
    
    //第一张时往前加载图片
    if (m_count > 0 && m_index == 0 && m_zero)
    {
        if (m_imgCount > 0)
        {
            m_updata = YES;
            [self WaitMessageDialogShow];
            
            [self performSelector:@selector(loadAnotherImage) withObject: nil afterDelay:0.4f];
        }
    }
    
    //第一张但却不是图片列表的第一张时加载图片
    if (m_count == 0 && m_index == 0 && m_zero)
    {
        if (m_imageIndex > 0 && m_objList->itemAt(m_imageIndex))
        {
            m_count = 1;
            if (!m_setvalue)
            {
                m_imgCount = m_imageIndex;
                m_setvalue = YES;
            }
            
            if (m_objList->itemAt(m_imgCount) != m_objList->itemAt(0))
            {
                m_updata = YES;
                [self WaitMessageDialogShow];
                
                [self performSelector:@selector(loadAnotherImage) withObject: nil afterDelay:0.4f];
            }
        }
    }
}

-(void)WaitMessageDialogShow
{
    m_alert = [[[UIAlertView alloc] initWithTitle:@"Please Wait ... "
                                          message:nil
                                         delegate:self
                                cancelButtonTitle:nil
                                otherButtonTitles: nil] autorelease];
    [m_alert show];
    
    UIActivityIndicatorView * aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.center = CGPointMake(m_alert.bounds.size.width/2.0f, m_alert.bounds.size.height/2.0f);
    [aiv startAnimating];
    [m_alert addSubview:aiv];
    [aiv release];   
}

-(void)dealloc
{
    [_thumbsGridView release];
    [_photoGridView release];
    [_resizeThumb release];
    [_photoDS release];
    [serverList release];
    [delegate release];
    [_singleRowThumbDS release];
    [_thumbsDS release];
    
    [super dealloc];
}

-(void)gridView:(IGGridView *)gridView didSelectCellAtPath:(IGCellPath *)path
{
    IGGridViewDataSourceHelper* ds = _thumbsGridView.dataSource;
    
    path = [ds normalizePath:path];
    path = [_photoDS deNormalizePath:path];
    
    [_photoGridView scrollToCellAtCellPath:path atScrollPosition:IGGridViewScrollPositionTopLeft animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    bool isIphone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    return isIphone? (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) :YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateLayoutForOrientation:toInterfaceOrientation usingDuration:duration];
}

-(void)updateLayoutForOrientation:(UIInterfaceOrientation)interfaceOrientation usingDuration:(NSTimeInterval)duration
{
    CGFloat size = _columnSize* _numberOfColumns;
    
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [UIView animateWithDuration:duration animations:^{
            _thumbsGridView.frame  = CGRectMake(0, 0, size, _landscapeSize.height);
            _photoGridView.frame = CGRectMake(size + _resizeThumbSize, 0, _landscapeSize.width - (size + _resizeThumbSize), _landscapeSize.height);
        }];
        
        [self updateDataForOrientation:YES];
    }
    else
    {
        [UIView animateWithDuration:duration animations:^{
            _thumbsGridView.frame  = CGRectMake(0, _portraitSize.height - size - 25, _portraitSize.width, size);
            _photoGridView.frame = CGRectMake(0, 0, _portraitSize.width, _portraitSize.height - (size + _resizeThumbSize));
        }];
        
        [self updateDataForOrientation:NO];
    }
}

-(void)updateDataForOrientation:(BOOL)isLandscape
{
    IGCellPath* path;
    if (![delegate currentRenderIsSelf] && !m_updata)
    {
        path = [_thumbsGridView pathForSelectedCell];
    }
    else
    {
        path = [_photoGridView pathForSelectedCell];
    }
    // path = [_photoGridView pathForSelectedCell];
    IGGridViewDataSourceHelper* ds = _thumbsGridView.dataSource;
    path = [ds normalizePath:path];
    
    if(isLandscape)
    {
        _thumbsGridView.dataSource = _thumbsDS;
        _thumbsGridView.columnWidth = [[IGColumnWidth alloc]initWithFillAvailableSpacePercent:1];
        _thumbsDS.numberOfColumns = _numberOfColumns;
        [_thumbsDS invalidateData];
        
        _thumbsGridView.allowHorizontalBounce = NO;
        _thumbsGridView.alwaysBounceHorizontal = NO;
        _thumbsGridView.alwaysBounceVertical = YES;
    }
    else
    {
        if(_numberOfColumns == 1)
        {
            _thumbsGridView.dataSource = _singleRowThumbDS;
            _thumbsGridView.columnWidth = [[IGColumnWidth alloc]initWithWidth:_portraitSize.width/_portraitColumnCount];
            _thumbsGridView.allowHorizontalBounce = YES;
            _thumbsGridView.alwaysBounceHorizontal = YES;
            _thumbsGridView.alwaysBounceVertical = NO;
        }
        else
        {
            _thumbsGridView.dataSource = _thumbsDS;
            _thumbsGridView.columnWidth = [[IGColumnWidth alloc]initWithFillAvailableSpacePercent:1];
            _thumbsDS.numberOfColumns = _portraitColumnCount;
            [_thumbsDS invalidateData];
            
            _thumbsGridView.allowHorizontalBounce = NO;
            _thumbsGridView.alwaysBounceHorizontal = NO;
            _thumbsGridView.alwaysBounceVertical = YES;
        }
    }
    
    if (m_updata)
    {
        m_updata = NO;
        _photoGridView.dataSource = _photoDS;
        [_photoGridView reloadData];
        
        IGGridViewDataSourceHelper* currentDS = _photoGridView.dataSource;
        path = [currentDS deNormalizePath:path];
        
        [_photoGridView selectCellAtPath:path animated:NO scrollPosition:IGGridViewScrollPositionNone];
        [_photoGridView scrollToCellAtCellPath:path atScrollPosition:IGGridViewScrollPositionNone animated:NO];
    }
    
    [_thumbsGridView updateData];
    
    IGGridViewDataSourceHelper* currentDS = _thumbsGridView.dataSource;
    path = [currentDS deNormalizePath:path];
    
    
    [_thumbsGridView selectCellAtPath:path animated:NO scrollPosition:IGGridViewScrollPositionNone];
    [_thumbsGridView scrollToCellAtCellPath:path atScrollPosition:IGGridViewScrollPositionNone animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLayoutForOrientation:self.interfaceOrientation usingDuration:0];
}

-(void)getSourceIndex:(NSInteger)index
{
    m_imageIndex = index;
}
@end






@implementation PhotoInfo

@synthesize imagePath, thumbPath, imageData, thumbData;

-(UIImage *)image
{
    UIImage *img = [UIImage imageWithData:imageData];
    
    return img;
}

-(UIImage *)thumb
{
    UIImage* oldimg = [UIImage imageWithData:imageData];
    UIImage *img = [oldimg scaleToSize:CGSizeMake(75.0,65.0)];
    
    return img;
    
}

-(void)dealloc
{
    [imagePath release];
    [thumbPath release];
    [imageData release];
    [thumbData release];
    [super dealloc];
}
@end


@implementation UIImage(UIImageScale)

-(UIImage*)scaleToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)*0.5;
    int yPos = (size.height-height)*0.5;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}
@end

