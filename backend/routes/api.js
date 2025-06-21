const express = require('express');
const router = express.Router();
const database = require('../database');
const { ObjectId } = require('mongodb');

// Helper function to handle async routes
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Test endpoint
router.get('/test', (req, res) => {
  res.json({ message: 'Grocery Store API is working!', timestamp: new Date() });
});

// Authentication endpoints
router.post('/auth/register', asyncHandler(async (req, res) => {
  const { name, email, phone, password } = req.body;

  if (!name || !email || !phone || !password) {
    return res.status(400).json({
      success: false,
      message: 'Please provide all required fields'
    });
  }

  try {
    // 检查邮箱是否已注册
    const existingUser = await database.getUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'Email already registered'
      });
    }

    // 检查手机号是否已注册
    const existingPhoneUser = await database.getUserByPhone(phone);
    if (existingPhoneUser) {
      return res.status(409).json({
        success: false,
        message: 'Phone number already registered'
      });
    }

    const userId = await database.createUser({ name, email, phone, password });
    const user = await database.validateUser(email, password);
    const token = database.generateAuthToken(user);

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email
        }
      }
    });
    // res.status(201).json({
    //   success: true,
    //   data: { userId }
    // });
  } catch (error) {
    let statusCode = 400;
    let errorMessage = error.message;

    if (error.message.includes('validation failed')) {
      errorMessage = 'Invalid user data provided';
    } else if (error.message.includes('duplicate key')) {
      statusCode = 409;
      errorMessage = 'User already exists';
    }

    res.status(statusCode).json({
      success: false,
      message: errorMessage
    });
  }
}));

router.post('/auth/login', asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Please provide email and password'
    });
  }

  try {
    const user = await database.validateUser(email, password);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication failed'
      });
    }

    const token = database.generateAuthToken(user);

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email
        }
      }
    });
  } catch (error) {
    let statusCode = 401;
    let errorMessage = error.message;

    if (error.message === 'User not found') {
      statusCode = 404;
      errorMessage = 'No account found with this email';
    } else if (error.message === 'Incorrect password') {
      errorMessage = 'The password you entered is incorrect';
    } else if (error.message === 'Account not properly set up') {
      statusCode = 403;
      errorMessage = 'Account setup incomplete';
    }

    res.status(statusCode).json({
      success: false,
      message: errorMessage
    });
  }
}));

//手机号密码登录
router.post('/auth/phone/login', asyncHandler(async (req, res) => {
  const { phone, password } = req.body;

  if (!phone || !password) {
    return res.status(400).json({
      success: false,
      message: 'Please provide email and password'
    });
  }

  try {
    const user = await database.validatePhone(phone, password);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication failed'
      });
    }

    const token = database.generateAuthToken(user);

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email
        }
      }
    });
  } catch (error) {
    let statusCode = 401;
    let errorMessage = error.message;

    if (error.message === 'User not found') {
      statusCode = 404;
      errorMessage = 'No account found with this email';
    } else if (error.message === 'Incorrect password') {
      errorMessage = 'The password you entered is incorrect';
    } else if (error.message === 'Account not properly set up') {
      statusCode = 403;
      errorMessage = 'Account setup incomplete';
    }

    res.status(statusCode).json({
      success: false,
      message: errorMessage
    });
  }
}));

//重设密码
router.post('/auth/reset/password', asyncHandler(async (req, res) => {
  const { phone, password } = req.body;

  if (!phone || !password) {
    return res.status(400).json({
      success: false,
      message: 'Please provide email and password'
    });
  }

  try {
    const user = await database.resetPassword(phone, password);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication failed'
      });
    }

    const token = database.generateAuthToken(user);

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email
        }
      }
    });
  } catch (error) {
    let statusCode = 401;
    let errorMessage = error.message;

    if (error.message === 'User not found') {
      statusCode = 404;
      errorMessage = 'No account found with this email';
    } else if (error.message === 'Incorrect password') {
      errorMessage = 'The password you entered is incorrect';
    } else if (error.message === 'Account not properly set up') {
      statusCode = 403;
      errorMessage = 'Account setup incomplete';
    }

    res.status(statusCode).json({
      success: false,
      message: errorMessage
    });
  }
}));

// 更新用户信息接口
router.post('/auth/user/update', asyncHandler(async (req, res) => {
  const { id, firstName, lastName, phone, gender, birthday } = req.body;

  if (!id) {
    return res.status(400).json({
      success: false,
      message: 'User ID is required',
    });
  }

  try {
    const db = database.getDb();

    // 找出用户
    const existingUser = await db.collection('users').findOne({ _id: new ObjectId(id) });
    if (!existingUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // 校验手机号是否重复（只有在用户真的修改了手机号时检查）
    if (phone && phone !== existingUser.phone) {
      const phoneUser = await db.collection('users').findOne({ phone });
      if (phoneUser) {
        return res.status(409).json({ success: false, message: 'Phone number already in use' });
      }
    }

    // 按需更新这些字段，不传入则不更新
    const updateFields = {};
    if (firstName) updateFields.firstName = firstName;
    if (lastName) updateFields.lastName = lastName;
    if (phone) updateFields.phone = phone;
    if (gender) updateFields.gender = gender;
    if (birthday) updateFields.birthday = birthday;

    // 没有任何需要更新的字段
    if (Object.keys(updateFields).length === 0) {
      return res.status(400).json({ success: false, message: 'No valid fields to update' });
    }

    // 只更新传入字段，不影响其他原有字段，比如 password、email、_id 都自动保留
    await db.collection('users').updateOne(
        { _id: new ObjectId(id) },
        { $set: updateFields }
    );

    // 获取更新后的用户信息
    const updatedUser = await db.collection('users').findOne({ _id: new ObjectId(id) });

    res.status(200).json({
      success: true,
      message: 'User updated successfully',
      data: updatedUser,
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ success: false, message: 'Internal Server Error', error: error.message });
  }
}));

// 获取用户信息接口
router.post('/auth/userById', asyncHandler(async (req, res) => {
  const { id } = req.body;
  if (!id) {
    return res.status(400).json({ success: false, message: 'User ID is required' });
  }

  try {
    const db = database.getDb();
    const { ObjectId } = require('mongodb');

    // 根据 id 查找用户
    const user = await db.collection('users').findOne(
        { _id: new ObjectId(id) },
        { projection: { password: 0 } } // 排除密码字段
    );

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.status(200).json({ success: true, data: user });
  } catch (error) {
    console.error('Error fetching user by ID:', error);
    res.status(500).json({ success: false, message: 'Internal Server Error', error: error.message });
  }
}));



// Categories endpoints
router.get('/categories', asyncHandler(async (req, res) => {
  try {
    const categories = await database.getCategories();
    res.json({
      success: true,
      data: categories,
      count: categories.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch categories',
      error: error.message
    });
  }
}));

router.get('/categories/:id', asyncHandler(async (req, res) => {
  try {
    const category = await database.getCategoryById(req.params.id);
    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }
    res.json({
      success: true,
      data: category
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch category',
      error: error.message
    });
  }
}));

// Products endpoints
router.get('/products', asyncHandler(async (req, res) => {
  try {
    const filters = {};

    // Parse query parameters
    if (req.query.categoryId) filters.categoryId = req.query.categoryId;
    if (req.query.isNew) filters.isNew = req.query.isNew === 'true';
    if (req.query.isPopular) filters.isPopular = req.query.isPopular === 'true';
    if (req.query.isActive) filters.isActive = req.query.isActive === 'true';

    const products = await database.getProducts(filters);
    res.json({
      success: true,
      data: products,
      count: products.length,
      filters: filters
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch products',
      error: error.message
    });
  }
}));

router.get('/products/:id', asyncHandler(async (req, res) => {
  try {
    const product = await database.getProductById(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    res.json({
      success: true,
      data: product
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch product',
      error: error.message
    });
  }
}));

// Search products
router.get('/products/search/:term', asyncHandler(async (req, res) => {
  try {
    const searchTerm = req.params.term;
    const products = await database.searchProducts(searchTerm);
    res.json({
      success: true,
      data: products,
      count: products.length,
      searchTerm: searchTerm
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to search products',
      error: error.message
    });
  }
}));

// Bundles endpoints
router.get('/bundles', asyncHandler(async (req, res) => {
  try {
    const filters = {};

    // Parse query parameters
    if (req.query.categoryId) filters.categoryId = req.query.categoryId;
    if (req.query.isPopular) filters.isPopular = req.query.isPopular === 'true';
    if (req.query.isActive) filters.isActive = req.query.isActive === 'true';

    const bundles = await database.getBundles(filters);
    res.json({
      success: true,
      data: bundles,
      count: bundles.length,
      filters: filters
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch bundles',
      error: error.message
    });
  }
}));

// Get bundle details with populated products
router.get('/bundles/:id', async (req, res) => {
  try {
    const bundleId = req.params.id;
    const db = database.getDb();

    let query;
    // Check if it's a valid ObjectId format
    if (ObjectId.isValid(bundleId) && bundleId.length === 24) {
      query = { _id: new ObjectId(bundleId) };
    } else {
      // Treat as string ID (for mock data compatibility)
      query = { $or: [{ id: bundleId }, { name: bundleId }] };
    }

    // Add isActive filter
    query.isActive = true;

    // Get bundle by ID
    const bundle = await db.collection('bundles').findOne(query);

    if (!bundle) {
      return res.status(404).json({
        success: false,
        message: 'Bundle not found'
      });
    }

    // Populate products in bundle items
    if (bundle.items && bundle.items.length > 0) {
      const productIds = bundle.items.map(item => item.productId);
      const products = await db.collection('products').find({
        _id: { $in: productIds },
        isActive: true
      }).toArray();

      // Create a map for quick lookup
      const productMap = {};
      products.forEach(product => {
        productMap[product._id.toString()] = product;
      });

      // Add product details to bundle items
      bundle.items = bundle.items.map(item => ({
        ...item,
        productDetails: productMap[item.productId.toString()] || null
      }));
    }

    res.json({ success: true, data: bundle });
  } catch (error) {
    console.error('Error fetching bundle details:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch bundle details',
      error: error.message
    });
  }
});

// Error handling middleware
router.use((error, req, res, next) => {
  console.error('API Error:', error);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: error.message
  });
});

module.exports = router; 