<cfcomponent extends="org.lucee.cfml.test.LuceeTestCase">
	<cfscript>
		// skip closure
		function isNotSupported() {
			variables.s3Details=getCredentials();
			if(!isNull(variables.s3Details.ACCESSKEYID) && !isNull(variables.s3Details.AWSSECRETKEY)) {
				variables.supported = true;
			}
			else
				variables.supported = false;

			return !variables.supported;
		}

		function beforeAll() skip="isNotSupported"{
			if(isNotSupported()) return;
			s3Details = getCredentials();
			mitrahsoftBucketName = "testcasesLDEV1396";
			base = "s3://#s3Details.ACCESSKEYID#:#s3Details.AWSSECRETKEY#@";
			variables.baseWithBucketName = "s3://#s3Details.ACCESSKEYID#:#s3Details.AWSSECRETKEY#@/#mitrahsoftBucketName#";
			// for skipping rest of the cases, if error occurred.
			hasError = false;
			// for replacing s3 access keys from error msgs
			regEx = "\[[a-zA-Z0-9\:\/\@]+\]";
		}

		function afterAll() skip="isNotSupported"{
			if(isNotSupported()) return;
			// if( directoryExists(baseWithBucketName) )
			// 	directoryDelete(baseWithBucketName, true);
		}

		public function run( testResults , testBox ) {
			describe( title="Test suite for LDEV-1396 ( checking s3 file operations )", body=function() {
				it(title="Creating a new s3 bucket", skip=isNotSupported(), body=function( currentSpec ) {
					if(isNotSupported()) return;
					if( directoryExists(baseWithBucketName))
						directoryDelete(baseWithBucketName, true);
					directoryCreate(baseWithBucketName);
				});

				it(title="checking cffile, with attribute storeAcl = 'private' ", skip=isNotSupported(), body=function( currentSpec ){
					cffile (action="write", file=baseWithBucketName & "/test.txt", output="Sample s3 text", storeAcl="private");
					var acl = StoreGetACL( baseWithBucketName & "/test.txt" );
					expect(arrayisEmpty(acl)).toBe(true);
				});

				it(title="checking cffile, with attribute storeAcl value as aclObject (an array of struct where struct represents an ACL grant)", skip=isNotSupported(), body=function( currentSpec ){
					arr=[{'group':"all",'permission':"read"}];
					cffile (action="write", file=baseWithBucketName & "/test.txt", output="Sample s3 text", storeAcl="#arr#");
					var acl = StoreGetACL( baseWithBucketName & "/test.txt" );
					expect(acl[1].permission).toBe("read");
				});
			});
		}

		// Private functions
		private struct function getCredentials() {
			var s3 = {};
			if(!isNull(server.system.environment.S3_ACCESS_ID) && !isNull(server.system.environment.S3_SECRET_KEY)) {
				// getting the credentials from the environment variables
				s3.ACCESSKEYID=server.system.environment.S3_ACCESS_ID;
				s3.AWSSECRETKEY=server.system.environment.S3_SECRET_KEY;
			}else if(!isNull(server.system.properties.S3_ACCESS_ID) && !isNull(server.system.properties.S3_SECRET_KEY)) {
				// getting the credentials from the system variables
				s3.ACCESSKEYID=server.system.properties.S3_ACCESS_ID;
				s3.AWSSECRETKEY=server.system.properties.S3_SECRET_KEY;
			}
			return s3;
		}
	</cfscript>
</cfcomponent>
