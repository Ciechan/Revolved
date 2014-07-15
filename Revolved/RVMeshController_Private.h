//
//  RVMeshController_Private.h
//  Revolved
//
//  Created by Bartosz Ciechanowski on 10.08.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "RVMeshController.h"

@interface RVMeshController ()
{
    @protected
    GLuint _VAO;
    GLuint _indiciesCount;
    
    GLuint _indexBuffer;
    GLuint _vertexBuffer;

}

- (void)setupVAO;

@end
