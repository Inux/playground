import HtmlWebpackPlugin from 'html-webpack-plugin';

module.exports = {
	// Your main js file
	entry: './src/js/app.js',
	// Production set up
	output: {
		path: __dirname + 'dist',
		filename: 'bundle.min.js'
	},

	module: {
		rules: [
			{
				// Finds all .js files in project
				test: /\.js?$/,
				exclude: /node_modules/,
                loader: 'babel-loader',
                options: {
                    presets: ['@babel/preset-env']
                }
			},
			{
				test: /\.scss?$/,
				loader: 'style-loader!css-loader!sass-loader'
			}
		]
	},

	plugins: [
		new HtmlWebpackPlugin({
			minify: { collapseWhitespace: true },
			// Write all your html in this file
			template: './src/index.ejs',
		})
	],

	node: false,
	devtool: 'source-map',

	devServer: {
		// Set a port number to your liking
		port: process.env.PORT || 8666,
		contentBase: './src',
		historyApiFallback: false
	}
};
