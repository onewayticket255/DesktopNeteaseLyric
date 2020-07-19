#include "NLSRootListController.h"
#include <spawn.h>

@implementation NLSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}


extern char **environ;
void run_cmd(char *cmd)
{
	pid_t pid;
	char *argv[] = {"sh", "-c", cmd, NULL};
	int status;

	status = posix_spawn(&pid, "/bin/sh", NULL, NULL, argv, environ);
	if (status == 0)
	{
		if (waitpid(pid, &status, 0) == -1)
		{
			perror("waitpid");
		}
	}
}


-(void)killSpringBoard {
	run_cmd("killall -9 SpringBoard");
}

-(void) openGithub{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/onewayticket255/DesktopNeteaseLyric"] options:@{} completionHandler:nil];
}

@end
